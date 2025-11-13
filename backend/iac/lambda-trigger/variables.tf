# lambda-trigger/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "The prefix for all resources"
  type        = string
  default     = "cloud-etl-pokeapi"
}

variable "lambda_handler_name" {
  description = "The name of the Lambda handler file"
  type        = string
  default     = "lambda_handler"
}