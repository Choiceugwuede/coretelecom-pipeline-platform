#User for airbyte and access to roles
resource "snowflake_user" "airbyte" {
  name     = "airbyte_user"
  password = data.aws_ssm_parameter.airbyte_password.value
  default_role = module.airbyte_role.name
  default_warehouse = "COMPUTE_WH"
  comment  = "Airbyte ingestion user"
}

