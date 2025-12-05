def _extract_load_social_media():

    import pandas as pd
    from include.extract_from_s3 import _extract_from_s3
    from include.load_to_s3 import _load_parquet
    from datetime import datetime, timedelta

    # date = (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d") - if it would have been a daily load for D-1

    # start and end date of historical files available
    start_date = datetime.strptime("2025-11-20", "%Y-%m-%d")
    end_date = datetime.strptime("2025-11-23", "%Y-%m-%d")
    prefix = 'raw/social_medias/'

    current_date = start_date

    while current_date <= end_date:
        date = current_date.strftime("%Y-%m-%d")

        source_file = f'social_medias/media_complaint_day_{date}.json'
        filename = f'media_complaint_day_{date}.parquet'

        social_media = _extract_from_s3(source_file)

        _load_parquet(social_media, prefix, filename)

        current_date += timedelta(days=1)