data "aws_ssm_parameter" "snowflake_organization" {
  name = "/coretelcom/snowflake/organization"
}

data "aws_ssm_parameter" "snowflake_account" {
  name = "/coretelcom/snowflake/account"
}

data "aws_ssm_parameter" "snowflake_password" {
  name = "/coretelcom/snowflake/password"
  with_decryption = true
}

data "aws_ssm_parameter" "snowflake_host" {
  name = "/coretelcom/snowflake/host"
}

data "aws_ssm_parameter" "snowflake_username" {
  name = "/coretelcom/snowflake/username"
}

data "aws_ssm_parameter" "airbyte_password" {
  name = "/coretelcom/snowflake/airbyte/password"
  with_decryption = true
}

data "aws_ssm_parameter" "airbyte_token" {
  name = "/coretelcom/airbyte/token"
  with_decryption = true
}

data "aws_ssm_parameter" "airbyte_client_id" {
  name = "/coretelcom/airbyte/client/id"
}

data "aws_ssm_parameter" "airbyte_client_secret" {
  name = "/coretelcom/airbyte/client/secret"
  with_decryption = true
}

data "aws_ssm_parameter" "airbyte_workspace" {
  name = "/coretelcom/airbyte/workspace/id"
}

data "aws_ssm_parameter" "aws_access_key" {
  name = "/coretelcom/aws/access/key"
}

data "aws_ssm_parameter" "aws_secret_key" {
  name = "/coretelcom/aws/secret/key"
  with_decryption = true
}



