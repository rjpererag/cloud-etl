# Data sources for existing VPC and Subnet
# We retrieve the default VPC ID

data "aws_vpc" "default" {
  default = true
}

# We retrieve all public subnets in the default VPC.
# Fargate on FARGATE_ONLY ECS clusters requires public subnets for external access
# (to pull the image from ECR and call the PokeAPI)

data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = [true]
  }
}

# Fargate Security Group
# This Security Group will be attached to the Fargate Task
resource "aws_security_group" "ecs_sg" {
  name = "cloud-etl-pokeapi-ecs-sg-tf"
  description = "Allows outbound traffic for ECR pull and PokeAPI access"
  vpc_id = data.aws_vpc.default.id

  # By default, Terraform removes the AWS default egress (outbound) rule.
  # We must explicitly add a rule to allow the container to access the internet.
  egress {
    from_port = 0 # All ports
    to_port = 0 # All ports
    protocol = "-1" # All protocols (TCP, UDP, ICMP)
    cidr_blocks = ["0.0.0.0/0"] # The entire internet
    description = "Allow all outbound internet access"
  }
  tags = {
    Name = "cloud-etl-pokeapi-ecs-sg-tf"
  }
}

# Output the networking details
output "vpc_id" {
  description = "The ID of the default VPC used by ECS"
  value       = data.aws_vpc.default.id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs in the default VPC"
  value       = data.aws_subnets.public.ids
}

output "ecs_security_group_id" {
  description = "The ID of the Security Group attached to the ECS Task"
  value       = aws_security_group.ecs_sg.id
}
