# Provider configuration
# backend/iac/versions.tf

terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source: "hashicorp/aws"
      version: "~> 5.0"
    }
  }

  backend "s3" {
      bucket         = "tf-state-cloud-etl-pokeapi-12345" # <-- MUST BE CREATED MANUALLY
      key            = "s3-buckets/terraform.tfstate"     # Location of this component's state
      region         = "eu-central-1"
      encrypt        = true                               # Recommended for security
      # dynamodb_table = "terraform-locks"                  # Recommended for state locking (optional but good practice)
    }
}


provider "aws" {
  region = var.aws_region
}