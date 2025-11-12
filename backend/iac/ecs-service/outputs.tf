# ecs-service/outputs.tf

# ECS and ECR Outputs
output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.main.id
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS Task Definition."
  value       = aws_ecs_task_definition.transformation_task.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.transformation_repo.repository_url
}

# Networking Outputs (from vpc.tf)
output "vpc_id" {
  description = "The ID of the default VPC used by ECS"
  value       = data.aws_vpc.default.id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs in the default VPC."
  value       = data.aws_subnets.public.ids
}

output "ecs_security_group_id" {
  description = "The ID of the Security Group attached to the ECS Task."
  value       = aws_security_group.ecs_sg.id
}