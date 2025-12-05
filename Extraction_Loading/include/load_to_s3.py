def _load_parquet(df, prefix, filename):
    """Writes a dataframe to s3 in parquet format 
    parameter:
    df: dataframe
    prefix: destination folder structure, e.g raw/customer
    filename: name.parquet
    """

    import awswrangler as wr
    import boto3
    from datetime import datetime, timezone
    from include.logging_config import get_logger
    import json

    logger = get_logger(__name__)

    bucket = "core-telcom-lake"
    metadata = {
        "filename": filename,
        "load_time": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
        "prefix": prefix
    }

    metadata_key = f"{prefix}{filename.replace('.parquet', '')}_metadata.json"
    path = f"s3://{bucket}/{prefix}{filename}"

    try:
        logger.info("Loading to S3 in Parquet format")

        wr.engine.set("python")
        wr.memory_format.set("pandas")

        wr.s3.to_parquet(
            df=df,
            path=path,
            index=False,
            dataset=True,
            mode="overwrite"
        )

        logger.info("Adding metadata")
        s3 = boto3.client("s3")
        s3.put_object(
            Bucket=bucket,
            Key=metadata_key,
            Body=json.dumps(metadata),
            ContentType="application/json"
        )

        logger.info("Metdata added")

        logger.info(f'Data written to {path}')
    except Exception as e:
        logger.error(f'unable to load to S3: {e}')
        raise
