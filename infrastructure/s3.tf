# Bucket for terraform backend state file 

resource "aws_s3_bucket" "tf_state" {
  bucket = "core-telcom-terraform-backend-state"

  lifecycle {
    prevent_destroy = true
  }

}

#enabling versioning on bucekt to see previous states
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = "core-telcom-terraform-backend-state"
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket for core telcom storage

resource "aws_s3_bucket" "core_telcom_lake" {
  bucket = "core-telcom-lake"
  
  lifecycle {
    prevent_destroy = true             
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = "core-telcom-lake"

  versioning_configuration {
    status = "Enabled"
  }
}


