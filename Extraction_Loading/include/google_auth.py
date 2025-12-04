def get_google_credentials():
    """google service account credentials"""

    from include.get_parameter import param

    creds_dict = {
        "type": "service_account",
        "project_id": "core-telcom",
        "private_key_id": param("/coretelcom/google/privatekey/id"),
        "private_key": param("/coretelcom/google/privatekey/value", decrypt=True),
        "client_email": param("/coretelcom/google/client-email"),
        "client_id": param("/coretelcom/google/client-id"),
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": param("/coretelcom/google/client_cert_url"),
        "universe_domain": "googleapis.com"
    }

    return creds_dict