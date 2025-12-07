from pathlib import Path
import boto3


def param(name: str, decrypt: bool = False) -> str:
    """Get parameter values from AWS SSM Parameter Store."""
    ssm = boto3.client("ssm", region_name="eu-north-1")
    response = ssm.get_parameter(Name=name, WithDecryption=decrypt)
    return response["Parameter"]["Value"]


# Retrieve Snowflake credentials from SSM
account = param("/coretelcom/snowflake/account_host")
password = param("/coretelcom/snowflake/password")
user = param("/coretelcom/snowflake/username")

# Create DBT profiles directory
profiles_dir = Path("/opt/airflow/.dbt")
profiles_dir.mkdir(parents=True, exist_ok=True)

# Build DBT profiles.yml content
profiles_content = f"""
dbt_transform:
  target: dev
  outputs:
    dev:
      account: {account}
      database: TELECOM_DB
      password: {password}
      role: ACCOUNTADMIN
      schema: DATAOPS
      threads: 4
      type: snowflake
      user: {user}
      warehouse: COMPUTE_WH
"""

# Write profiles.yml file
with open(profiles_dir / "profiles.yml", "w", encoding="utf-8") as f:
    f.write(profiles_content)
