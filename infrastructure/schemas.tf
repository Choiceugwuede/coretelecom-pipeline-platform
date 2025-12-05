resource "snowflake_schema" "bronze" {
  name     = "BRONZE"
  database = snowflake_database.telecom.name
}

resource "snowflake_schema" "dataops" {
  name     = "DATAOPS"
  database = snowflake_database.telecom.name
}

