def _extract_load_web_complaints():
    """Extract and load data from database source to S3 in parquet format."""

    import pandas as pd
    from datetime import datetime, timedelta
    from include.database_conn import _create_connection
    from include.load_to_s3 import _load_parquet
    from include.get_parameter import param
    from include.logging_config import get_logger

    connection = _create_connection()
    schema = param("/coretelecomms/database/table_schema_name")
    prefix = "raw/website_customer_complaints/"

    # Start and end date of historical files available
    start_date = datetime.strptime("2025-11-20", "%Y-%m-%d")
    end_date = datetime.strptime("2025-11-23", "%Y-%m-%d")
    logger = get_logger(__name__)

    current_date = start_date

    try:
        while current_date <= end_date:
            date_str = current_date.strftime("%Y_%m_%d")

            table = f"web_form_request_{date_str}"
            filename = f"{table}.parquet"

            query = f"SELECT * FROM {schema}.{table}"
            df = pd.read_sql(query, connection)

            _load_parquet(df, prefix, filename)

            current_date += timedelta(days=1)

    except Exception as e:
        logger.error(f"Error processing data: {e}")
        raise

    finally:
        if connection:
            connection.close()
            logger.info("Postgres connection closed")
