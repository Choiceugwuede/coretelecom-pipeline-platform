def param(name, decrypt=False):
        """get parameter values from aws ssm"""
        import boto3
        from include.logging_config import get_logger

        logger = get_logger(__name__)
        try:
                ssm = boto3.client("ssm", region_name="eu-north-1")
                logger.info(f'parameter retrived: {name}')
                return ssm.get_parameter(Name=name, WithDecryption=decrypt)["Parameter"]["Value"]
        except Exception as e:
                logger.error(f'parameter not retrieved: {e}')
