def _extract_load_call_center():

    import pandas as pd
    from include.extract_from_s3 import _extract_from_s3
    from include.load_to_s3 import _load_parquet
    from datetime import datetime, timedelta
    # D_1 = (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d") - if it would have been a daily load 

    # start and end date of historical files available
    start_date = datetime.strptime("2025-11-20", "%Y-%m-%d")
    end_date = datetime.strptime("2025-11-23", "%Y-%m-%d")
    prefix = 'raw/call logs/'

    current_date = start_date


    while current_date <= end_date:
        date = current_date.strftime("%Y-%m-%d")
        
        # construct source path and filename
        source_file = f"call logs/call_logs_day_{date}.csv"
        filename = f"call_logs_day_{date}.parquet"
        
        # extract CSV and load to S3
        call_log = _extract_from_s3(source_file)
        
        _load_parquet(call_log, prefix, filename)
        
        # move to next day
        current_date += timedelta(days=1)


        