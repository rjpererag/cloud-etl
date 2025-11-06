# Customizable values (region, prefix)
# backend/iac/variables.tf

variable "project_name" {
  description = "A unique prefix for all resources"
  type = string
  default = "cloud-etl-pokeapi"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type = string
  default = "eu-central-1"
}