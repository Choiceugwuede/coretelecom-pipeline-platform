from pathlib import Path
import boto3


def param(name, decrypt=False):
  """get parameter values from aws ssm""" 
  ssm = boto3.client("ssm", region_name="eu-north-1") 
  return ssm.get_parameter(Name=name, WithDecryption=decrypt)["Parameter"]["Value"]

account = param("/coretelcom/snowflake/account_host")
password = param("/coretelcom/snowflake/password")
user =  param("/coretelcom/snowflake/username")

profiles_dir = Path("/opt/airflow/.dbt")
profiles_dir.mkdir(parents=True, exist_ok=True)

profiles_content = f"""
default:
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

with open(profiles_dir / "profiles.yml", "w") as f:
    f.write(profiles_content)
