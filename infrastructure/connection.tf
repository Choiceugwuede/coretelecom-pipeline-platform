resource "airbyte_connection" "customers" {
  name           = "customers-connection"
  source_id      = airbyte_source_s3.s3_raw.source_id
  destination_id = airbyte_destination_snowflake.snowflake_dimension.destination_id
  status         = "active"
  schedule = {
    schedule_type = "cron"
    cron_expression = "0 50 8 ? * *"

  }

  configurations = {
    streams = [
      {
        name                    = "customers"
        sync_mode               = "incremental_append"
        destination_sync_mode   = "*_dedup"
        primary_key             = [["customer_id"]]
        
      }
    ]

    namespace_definition = "destination"
    namespace_format     = ""
    prefix               = ""
  }
}

resource "airbyte_connection" "agents" {
  name           = "agents-connection"
  source_id      = airbyte_source_s3.s3_raw.source_id
  destination_id = airbyte_destination_snowflake.snowflake_dimension.destination_id
  status         = "active"
  schedule = {
    schedule_type = "cron"
    cron_expression = "0 50 8 ? * *"

  }

  configurations = {
    streams = [
      {
        name                    = "agents"
        sync_mode               = "full_refresh_overwrite"
        destination_sync_mode   = "*_dedup"
        primary_key             = [["iD"]]
        cursor_field            = ["iD"]
        
      }
    ]

    namespace_definition = "destination"
    namespace_format     = ""
    prefix               = ""
  }
}

resource "airbyte_connection" "call_logs" {
  name           = "call-logs-connection"
  source_id      = airbyte_source_s3.s3_raw.source_id
  destination_id = airbyte_destination_snowflake.snowflake_facts.destination_id
  status         = "active"
  schedule = {
    schedule_type = "cron"
    cron_expression = "0 50 8 ? * *"

  }

  configurations = {
    streams = [
      {
        name                    = "call_center"
        sync_mode               = "incremental_append"
        destination_sync_mode   = "*_dedup"
        primary_key             = [["call ID"]]
        
        
      }
    ]

    namespace_definition = "destination"
    namespace_format     = ""
    prefix               = ""
  }
}

resource "airbyte_connection" "social_media" {
  name           = "social-media-connection"
  source_id      = airbyte_source_s3.s3_raw.source_id
  destination_id = airbyte_destination_snowflake.snowflake_facts.destination_id
  status         = "active"
  schedule = {
    schedule_type = "cron"
    cron_expression = "0 50 8 ? * *"

  }

  configurations = {
    streams = [
      {
        name                    = "social_media"
        sync_mode               = "incremental_append"
        destination_sync_mode   = "*_dedup"
        primary_key             = [["complaint_id"]]
        
        
      }
    ]

    namespace_definition = "destination"
    namespace_format     = ""
    prefix               = ""
  }
}

resource "airbyte_connection" "website_complaints" {
  name           = "website-complaints-connection"
  source_id      = airbyte_source_s3.s3_raw.source_id
  destination_id = airbyte_destination_snowflake.snowflake_facts.destination_id
  status         = "active"
  schedule = {
    schedule_type = "cron"
    cron_expression = "0 50 8 ? * *"

  }

  configurations = {
    streams = [
      {
        name                    = "website_customer_complaints"
        sync_mode               = "incremental_append"
        destination_sync_mode   = "*_dedup"
        primary_key             = [["request_id"]]
        
        
      }
    ]

    namespace_definition = "destination"
    namespace_format     = ""
    prefix               = ""
  }
}
