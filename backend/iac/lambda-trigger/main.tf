# lambda-trigger/main.tf

# 1. Reference the remote state from the S3 component
data "terraform_remote_state" "s3_infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-cloud-etl-pokeapi-12345"
    key    = "s3-buckets/terraform.tfstate"
    region = var.aws_region
  }
}

# 2. Reference the remote state from the ECS component
data "terraform_remote_state" "ecs_infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-cloud-etl-pokeapi-12345"
    key    = "ecs-service/terraform.tfstate"
    region = var.aws_region
  }
}

# Local values for easy referencing
locals {
  # ECS values (from ecs-service outputs)
  ecs_cluster_name        = data.terraform_remote_state.ecs_infrastructure.outputs.ecs_cluster_id
  ecs_task_definition_arn = data.terraform_remote_state.ecs_infrastructure.outputs.ecs_task_definition_arn
  subnet_ids              = data.terraform_remote_state.ecs_infrastructure.outputs.public_subnet_ids
  security_group_id       = data.terraform_remote_state.ecs_infrastructure.outputs.ecs_security_group_id

  # S3 values (from s3-buckets outputs)
  raw_bucket_name         = data.terraform_remote_state.s3_infrastructure.outputs.raw_bucket_name
}