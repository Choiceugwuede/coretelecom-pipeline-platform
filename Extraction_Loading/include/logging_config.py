def get_logger(name):
    """logging configuration set to write in log file"""

    import logging
    import os

    LOG_DIR = "/opt/airflow/logs/complaints_etl/"
    os.makedirs(LOG_DIR, exist_ok=True)

    LOG_FILE = os.path.join(LOG_DIR, "extract_load.log")

    # Configure logging once
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(LOG_FILE),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(name)
