resource "airbyte_source_s3" "s3_raw" {
  name         = "dev-s3-source"
  workspace_id = data.aws_ssm_parameter.airbyte_workspace.value

  configuration = {
    aws_access_key_id     = data.aws_ssm_parameter.aws_access_key.value
    aws_secret_access_key = data.aws_ssm_parameter.aws_secret_key.value
    bucket                = aws_s3_bucket.core_telcom_lake.bucket
    bucket_region         = "eu-north-1"

    streams = [
      {
        name  = "customers"
        globs = ["raw/customers/**/*.parquet"]
        format = {
         parquet_format = {}
        }
      },
      {
        name  = "agents"
        globs = ["raw/agents/**/*.parquet"]
        format = {
         parquet_format = {}
        }
      },
      {
        name  = "call_center"
        globs = ["raw/call logs/**/*.parquet"]
        format = {
         parquet_format = {}
        }
      },
      {
        name  = "social_media"
        globs = ["raw/social_medias/**/*.parquet"]
        format = {
        parquet_format = {}
        }
      },
      {
        name  = "website_customer_complaints"
        globs = ["raw/website_customer_complaints/**/*.parquet"]
        format = {
        parquet_format = {}
        }
      }
    ]

    delivery_method = {
      replicate_records = {}
    }
  }
}
