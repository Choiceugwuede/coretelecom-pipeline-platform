def _extract_load_agent():
    """Extract and load agent from google sheet to s3"""

    import pandas as pd
    from googleapiclient.discovery import build
    from google.oauth2 import service_account
    from include.google_auth import get_google_credentials
    from include.load_to_s3 import _load_parquet
    from include.logging_config import get_logger

    logger = get_logger(__name__)
    
    # Parameters
    prefix = 'raw/agents/'
    filename = 'agents.parquet'
    google_cred = get_google_credentials()
    SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
    creds = None

    try:
        creds = service_account.Credentials.from_service_account_info(
            google_cred, scopes=SCOPES) 
        logger.info("Succesfully verified google creds...")
    except Exception as e:
        logger.error(f'Failed to verify google cred: {e}')
        raise

    # The ID of spreadsheet.
    AGENT_SPREADSHEET_ID = "1FAIGWRI4F-dnMZ30nEqnZB2aZyzYGLincgDVBrIfWM4"
    range_name = "agents"

    try:
        service = build("sheets", "v4", credentials=creds)

        # Call the Sheets API
        sheet = service.spreadsheets()
        result = (
            sheet.values()
            .get(spreadsheetId=AGENT_SPREADSHEET_ID, range=range_name)
            .execute()
        )
        values = result.get("values", [])
        df = pd.DataFrame(values[1:], columns=values[0])   
        logger.info(f'Sucessfully extracted {range_name}')
    except Exception as err:
        logger.error(f'File not extracted: {err}')

    if df is not None:
        _load_parquet(df, prefix, filename)
    else:
        logger.error("Skipping load: df was not created due to previous errors.")
    