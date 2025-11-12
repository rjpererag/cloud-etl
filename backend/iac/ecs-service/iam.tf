# Define the trust relationship document used by both roles
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# 1. ECS Task Execution Role (ExecutionRoleArn)
# Used by the ECS agent to:
# 1. Pull the Docker image from ECR
# 2. Write container logs to CloudWatch

resource "aws_iam_role" "ecs_execution_role" {
  name = "cloud-etl-ecs-exec-role-tf"
  assume_role_policy = "data.aws_iam_policy_document.ecs_assume_role.json"
}

# Attach the AWS Managed Policy for execution permissions
resource "aws_iam_role_policy_attachment" "acs_exec_policy_attach" {
  role       = "aws_iam_role.ecs_execution.name"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (TaskRoleArn)
# Used by your container code (Boto3) to
# 1. Read the raw file from the S3 Raw Bucket
# 2. Write the processed file to the S3 Processed Bucket

resource "aws_iam_role" "ecs_task_role" {
  name = "cloud-etl-ecs-task-role-tf"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

# Define the custom policy for S3 read/write permissions
data "aws_iam_policy_document" "ecs_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    # Reference the RAW BUCKET from the S3 remote state
    resources = [
    "${data.terrform_remote_state.s3_infrastructure.outputs.raw_bucket_arn}",
    "${data.terrform_remote_state.s3_infrastructure.outputs.raw_bucket_arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    # Reference the PROCESSED BUCKET from the S3 remote state
    resources = [
      "${data.terraform_remote_state.s3_infrastructure.outputs.processed_bucket_arn}",
      "${data.terraform_remote_state.s3_infrastructure.outputs.processed_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "ecs_s3_policy" {
  name = "cloud-etl-ecs-s3-policy-tf"
  policy   = data.aws_iam_policy_document.ecs_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_s3_policy_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}