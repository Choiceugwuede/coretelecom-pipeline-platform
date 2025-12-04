def _create_connection():
    """Create engine to connect to postgres database for customer complaints"""
    
    from sqlalchemy import create_engine
    from include.get_parameter import param
    from include.logging_config import get_logger
    import psycopg2

    logger = get_logger(__name__)
 

    logger.info("Creating Postgres engine...")
    try:
        username=param("/coretelecomms/database/db_username")
        password=param("/coretelecomms/database/db_password")
        host=param("/coretelecomms/database/db_host")
        port=param("/coretelecomms/database/db_port")
        database=param("/coretelecomms/database/db_name")
        
        # engine = create_engine("postgresql+psycopg2://scott:tiger@localhost:5432/mydatabase")
        connection = psycopg2.connect(
            host=host,
            database = database, 
            password = password,
            user = username,
            port = port )
        
        cursor = connection.cursor()

        logger.info("Succesfully created postgres engine")
        return cursor      
    except Exception as e:
        logger.error(f"Failed creating Postgres engine: {e}")
        raise