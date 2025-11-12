# Core resource definitions (S3, IAM, Lambda, ECS)
# backend/iac/main.py

# ------------------------------------------------------------------------------------
# S3 BUCKETS DEFINITION
# ------------------------------------------------------------------------------------

# 1. Raw data layer S3 Bucket
resource "aws_s3_bucket" "raw_bucket" {
  bucket = "${var.project_name}-raw-data"
  tags = {
    Name = "Raw data landing zone for PokeAPI"
  }
}

# Enforce secure configuration: block all public access
resource "aws_s3_bucket_public_access_block" "raw_bucket_public_access" {
  bucket = aws_s3_bucket.raw_bucket.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}


# 1. Processed data layer S3 Bucket
resource "aws_s3_bucket" "processed_bucket" {
  bucket = "${var.project_name}-processed-data"
  tags = {
    Name = "Processed data for analytics comsumption"
  }
}

# Enforce secure configuration: block all public access
resource "aws_s3_bucket_public_access_block" "processed_bucket_public_access" {
  bucket = aws_s3_bucket.processed_bucket.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}

# ------------------------------------------------------------------------------------
# IAM ROLES DEFINITION
# ------------------------------------------------------------------------------------

# Data source to define the trust relationship policy (Who can assume this role?)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
  }
}


# The actual IAM role resource
resource "aws_iam_role" "etl_execution_role" {
  name = "${var.project_name}-ETL-Execution-Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Attach a managed policy for basic Lambda/ECS logging (CloudWatch access)
resource "aws_iam_role_policy_attachment" "basic_execution_policy" {
  role      = aws_iam_role.etl_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Data source to define the custom policy for S3 read/write access
data "aws_iam_policy_document" "s3_access_policy"{
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListObject",
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.raw_bucket.arn,
      "${aws_s3_bucket.raw_bucket.arn}/*",
      aws_s3_bucket.processed_bucket.arn,
      "${aws_s3_bucket.processed_bucket.arn}/*",
    ]
  }
}

# Create the custom policy
resource "aws_iam_policy" "etl_s3_access_policy" {
  name = "${var.project_name}-S3-Access-Policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.etl_execution_role.name
  policy_arn = aws_iam_policy.etl_s3_access_policy.arn
}















