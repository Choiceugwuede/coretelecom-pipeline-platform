terraform {
  backend "s3" {
    bucket = "core-telcom-terraform-backend-state"
    key    = "Dev/core_telcom/terraform.tfstate"
    region = "eu-north-1"
  }
}
