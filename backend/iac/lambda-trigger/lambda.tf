# lambda-trigger/lambda.tf

# ------------------------------------
# IAM ROLES
# ------------------------------------

# Define the trust policy (Lambda service can assume this role)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# Create the lambda execution tole
resource "aws_iam_role" "ecs_task_launcher_role" {
  name = "${var.project_name}-ecs-launcher-role-tf"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Policy document: gives lambda the minimum permissions needed to run ECS and write logs
data "aws_iam_policy_document" "lambda_ecs_policy" {
  statement {
    sid = "RunECSTask"
    effect = "Allow"
    actions = ["ecs:RunTask", ]
    # Restrict to only the cluster and task definition we created
    resources = [
      local.ecs_cluster_name,
      local.ecs_task_definition_arn,
    ]
  }

  statement {
    sid = "LoggingAndNetworking"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PassECSRoles"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    # The Lambda must be allowed to pass BOTH the Task Role and the Execution Role
    resources = [
      data.terraform_remote_state.ecs_infrastructure.outputs.ecs_task_role_arn,      # You need to expose this in ecs-service outputs
      data.terraform_remote_state.ecs_infrastructure.outputs.ecs_execution_role_arn, # You need to expose this in ecs-service outputs
    ]
  }
}

# Attach the custom policy to the role
resource "aws_iam_policy" "lambda_ecs_policy" {
  name = "${var.project_name}-ecs-launcher-policy-tf"
  policy = data.aws_iam_policy_document.lambda_ecs_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.ecs_task_launcher_role.name
  policy_arn = aws_iam_policy.lambda_ecs_policy.arn
}

# ------------------------------------
# LAMBDA FUNCTION DEFINITION
# ------------------------------------

# NOTE: You must provide the Python code for lambda_handler.py in a zip file.
# For now, we assume the code is packaged as 'lambda_code.zip' in this directory.
resource "aws_lambda_function" "ecs_task_launcher" {
  function_name = "${var.project_name}-ecs-launcher-lambda"
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.11"
  role = aws_iam_role.ecs_task_launcher_role.arn
  timeout = 60

  # This path must point to your zipped Python file
  filename = "lambda_code.zip"
  source_code_hash = filebase64sha256("lambda_code.zip")

  environment {
    variables = {
      ECS_CLUSTER_NAME = local.ecs_cluster_name
      ECS_TASK_FAMILY = element(split("/", local.ecs_task_definition_arn), 1)
      VPC_SUBNET_IDS = jsonencode(local.subnet_ids)
      ECS_SECURITY_GROUP = local.security_group_id
    }
  }
}

# ------------------------------------
# LAMBDA FUNCTION DEFINITION
# ------------------------------------

# Give S3 permission to invoke the lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_task_launcher.function_name
  principal     = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::${local.raw_bucket_name}"
}

# Configure S3 to notify lambda on object creation
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = local.raw_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.ecs_task_launcher.arn
    events = ["s3:ObjectCreated:*"]
    # filter_prefix = "data/"
    filter_suffix = ".json"
  }
  depends_on = [aws_lambda_permission.allow_s3_invoke]
}


























