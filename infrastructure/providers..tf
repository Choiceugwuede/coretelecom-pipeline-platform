terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    snowflake = {
      source = "snowflakedb/snowflake"
      version = "2.11.0"
    }

    airbyte = {
      source = "airbytehq/airbyte"
      version = "0.13.0"
  }
}
}


# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Environment = "Dev"
      Owner        = "Choice workflow"
      Project = "core-telcom-pipeline"
    }
  }
}



provider "snowflake" {
  organization_name = data.aws_ssm_parameter.snowflake_organization.value
  account_name  = data.aws_ssm_parameter.snowflake_account.value
  user = data.aws_ssm_parameter.snowflake_username.value
  password = data.aws_ssm_parameter.snowflake_password.value
  role     = "ACCOUNTADMIN"
}

provider "airbyte" {
  client_id = data.aws_ssm_parameter.airbyte_client_id.value
  client_secret = data.aws_ssm_parameter.airbyte_client_secret.value

}
  




