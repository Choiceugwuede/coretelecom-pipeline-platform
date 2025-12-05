def _extract_from_s3(filename):
    """Extract csv or json file from S3
    parameters:
    bucket name
    filename(key)

    returns a dataframe"""

    import pandas as pd
    import json
    import boto3
    from include.logging_config import get_logger

    logger = get_logger(__name__)

    logger.info(f"Extracting file from S3: {filename}")

    s3 = boto3.client("s3")
    bucket = 'core-telecoms-data-lake'

    # Detect file type from extension
    extension = filename.split(".")[-1].lower()

    try:

        if extension == 'csv':
            obj = s3.get_object(Bucket=bucket, Key=filename)
            df = pd.read_csv(obj['Body'])
            logger.info(f"CSV extraction successful: {filename}")
            return df

        elif extension == 'json':
            obj = s3.get_object(Bucket=bucket, Key=filename)
            data = obj["Body"].read()
            file = json.loads(data)  # load data into variable
            df = pd.DataFrame([file])  # convert to dataframe

            expanded_rows = []  # empty list to append unnested data

            row = df.iloc[0]  # get the row as series for easy itertaion

            keys = list(row[df.columns[0]].keys())
            for k in keys:
                new_row = {"key": k}
                for col, val in row.items():
                    new_row[col] = val.get(k)
                expanded_rows.append(new_row)

            logger.info(f"JSON extraction successful: {filename}")

            return pd.DataFrame(expanded_rows)

        else:
            logger.warning(f"Unsupported file format: {extension}")

    except Exception as e:
        logger.error(f"Error reading from S3 {filename}: {e}")
        raise
