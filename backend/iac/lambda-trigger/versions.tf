# lambda-trigger/versions.tf

terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source: "hashicorp/aws"
      version: "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-cloud-etl-pokeapi-12345" # <-- YOUR STATE BUCKET
    key            = "lambda-trigger/terraform.tfstate" # This component's state key
    region         = "eu-central-1"
    encrypt        = true
    # dynamodb_table = "terraform-locks" # Omitted for cost, as you requested
  }
}

provider "aws" {
  region = var.aws_region
}