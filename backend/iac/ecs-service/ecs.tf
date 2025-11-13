locals {
  task_family_name = "cloud-etl-pokeapi-transformation-task-tf"
  log_group_name   = "/ecs/${local.task_family_name}"
}

# ECR Repository
resource "aws_ecr_repository" "transformation_repo" {
  name = "cloud-etl-pokeapi-transformation-repo-tf"
  image_tag_mutability = "MUTABLE"
}

# ECR Cluster
resource "aws_ecs_cluster" "main" {
  name = "cloud-etl-pokeapi-cluster-tf"
}

# Task Definition
resource "aws_ecs_task_definition" "transformation_task" {
  family = local.task_family_name
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # Attach the IAM roles created in iam.tf
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name = "transformation-container",
      image = "${aws_ecr_repository.transformation_repo.repository_url}:latest",
      essential = true,

      # CloudWatch Log Configuration
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      },
      # Environment Variables (using bucket names from remote state)
      environment = [
        { name = "RAW_BUCKET", value = data.terraform_remote_state.s3_infrastructure.outputs.raw_bucket_name},
        { name = "PROCESSED_BUCKET", value = data.terraform_remote_state.s3_infrastructure.outputs.processed_bucket_name}
      ]
    }
  ])
}

# Create the CloudWatch Log Group referenced by the Task Definition
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = local.log_group_name
  retention_in_days = 7 # Adjust as needed
}
