resource "airbyte_destination_snowflake" "snowflake_dimension" {
  name          = "raw-dimension-tables"
  workspace_id  = data.aws_ssm_parameter.airbyte_workspace.value

  configuration = {
    username = snowflake_user.airbyte.name
    database  = snowflake_database.telecom.name
    host = data.aws_ssm_parameter.snowflake_host.value
    role = module.airbyte_role.name
    warehouse = "COMPUTE_WH"
    schema = snowflake_schema.bronze.name
     use_merge_for_upsert  = true

    credentials = {
      username_and_password = {
        password = data.aws_ssm_parameter.airbyte_password.value
        
      }
    }
    
  }
}


resource "airbyte_destination_snowflake" "snowflake_facts" {
  name          = "raw-facts-tables"
  workspace_id  = data.aws_ssm_parameter.airbyte_workspace.value
  
  configuration = {
    username = snowflake_user.airbyte.name
    database  = snowflake_database.telecom.name
    host = data.aws_ssm_parameter.snowflake_host.value
    role = module.airbyte_role.name
    warehouse = "COMPUTE_WH"
    schema = snowflake_schema.bronze.name
     use_merge_for_upsert  = false

    credentials = {
      username_and_password = {
        password = data.aws_ssm_parameter.airbyte_password.value
      
      }
    }
    
  }
}