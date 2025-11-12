# ecs-service/main.tf

# 1. Reference the remote state from your S3 configuration
data "terraform_remote_state" "s3_infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-cloud-etl-pokeapi-12345" # <-- UPDATE with your S3 state bucket
    key    = "s3-buckets/terraform.tfstate"     # <-- ASSUMING the key for your S3 config
    region = var.aws_region
  }
}

# Note: The other resources (IAM, ECR, ECS) are defined in iam.tf, ecs.tf, and vpc.tf.