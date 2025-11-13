# Values to display after deployment
# backend/iac/s3-bucket/outputs.tf

output "raw_bucket_name" {
  description = "The Name of the S3 raw data bucket for environment variables."
  value       = aws_s3_bucket.raw_bucket.bucket
}

output "raw_bucket_id" {
  description = "The ID of the S3 raw data bucket"
  value = aws_s3_bucket.raw_bucket.id
}

output "raw_bucket_arn" {
  description = "The ARN of the S3 raw data bucket"
  value = aws_s3_bucket.raw_bucket.arn
}

output "processed_bucket_name" {
  description = "The Name of the S3 processed data bucket for environment variables."
  value       = aws_s3_bucket.processed_bucket.bucket
}

output "processed_bucket_arn" {
  description = "The ARN of the S3 processed data bucket for IAM policies."
  # This is the crucial ARN required by the ECS Task Role policy
  value       = aws_s3_bucket.processed_bucket.arn
}

output "etl_execution_role_arn" {
  description = "ARN of the IAM role used by Lambda/ECS"
  value = aws_iam_role.etl_execution_role.arn
}