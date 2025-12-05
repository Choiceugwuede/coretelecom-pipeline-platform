module "airbyte_role" {
  source  = "getindata/role/snowflake"
  version = "4.1.0"

  name = "airbyte_process"

  granted_to_users = [snowflake_user.airbyte.name]

  account_objects_grants = {
     "WAREHOUSE" = [
    {
      all_privileges = true
      with_grant_option = true
      object_name = "COMPUTE_WH"
    }
  ]
    "DATABASE" = [
      {
        privileges    = ["USAGE", "CREATE SCHEMA"]
        object_name    = snowflake_database.telecom.name
              }
    ]
  }

  schema_grants = [
    {
      database_name = snowflake_database.telecom.name
      schema_name   = snowflake_schema.bronze.name
      privileges    = ["USAGE","CREATE TABLE", "MODIFY", "MONITOR", "CREATE STAGE"]
  

    },
    {
        database_name = snowflake_database.telecom.name
        schema_name = snowflake_schema.dataops.name
        privileges = ["USAGE", "CREATE TABLE"]
    }
    
  ]

  schema_objects_grants = {
    TABLE = [
      {
        database_name = snowflake_database.telecom.name
        schema_name   = snowflake_schema.bronze.name
        on_future     = true
        privileges    = ["SELECT", "INSERT", "UPDATE", "DELETE"]
      }
    ]
  }
}