def _extract_load_customer():
    """extract from s3 and load to destination bucket in parquet format"""

    import pandas as pd
    from include.extract_from_s3 import _extract_from_s3
    from include.load_to_s3 import _load_parquet

    source_file = 'customers/customers_dataset.csv'
    prefix = 'raw/customers/'
    filename = 'customers.parquet'

    customers = _extract_from_s3(source_file)

    # load to parquet in core telcom bucket 
    _load_parquet(customers, prefix, filename)
