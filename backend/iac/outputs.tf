# Values to display after deployment
# backend/iac/outputs.tf

output "raw_bucket_id" {
  description = "The ID of the S3 raw data bucket"
  value = aws_s3_bucket.raw_bucket.id
}

output "etl_execution_role_arn" {
  description = "ARN of the IAM role used by Lambda/ECS"
  value = aws_iam_role.etl_execution_role.arn
}