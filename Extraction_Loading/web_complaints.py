def _extract_load_web_complaints():
    """extract and load data from database source to s3 in parquet format"""

    import pandas as pd
    from datetime import datetime, timedelta
    from include.database_conn import _create_connection
    from include.load_to_s3 import _load_parquet
    from include.get_parameter import param

    # date = (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d") - if it would have been a daily load for D-1


    engine = _create_connection()
    schema = param("/coretelecomms/database/table_schema_name")
    prefix = 'raw/website_customer_complaints/'

    # start and end date of historical files available
    start_date = datetime.strptime("2025-11-20", "%Y-%m-%d")
    end_date = datetime.strptime("2025-11-23", "%Y-%m-%d")

    current_date = start_date 

    while current_date <= end_date:
        date = current_date.strftime("%Y_%m_%d")

        table = f'web_form_request_{date}'
        filename = f'{table}.parquet'

        query = f'SELECT * FROM {schema}.{table}'
        with engine.connect() as conn:
            df = pd.read_sql(query, conn)
     

        _load_parquet(df,prefix,filename)
        
        current_date += timedelta(days=1)
