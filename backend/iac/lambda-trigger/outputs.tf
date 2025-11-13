# lambda-trigger/outputs.tf

output "lambda_function_name" {
  description = "The name of the Lambda function created to launch the ECS Task."
  value       = aws_lambda_function.ecs_task_launcher.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.ecs_task_launcher.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM Role assumed by the Lambda function."
  value       = aws_iam_role.ecs_task_launcher_role.arn
}