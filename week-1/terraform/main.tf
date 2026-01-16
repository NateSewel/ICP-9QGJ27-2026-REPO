# Terraform Configuration for Hello World App Deployment
# InternCareer Path - Week 1
# Intern ID: ICP-9QGJ27-2026

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "DevOps-Internship"
      InternID    = "ICP-9QGJ27-2026"
      Week        = "1"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "devops-internship-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-internship-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-internship-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "devops-internship-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app_server" {
  name        = "devops-internship-sg"
  description = "Security group for DevOps internship hello world app"
  vpc_id      = aws_vpc.main.id

  # HTTP access for application
  ingress {
    description = "Application port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict this to your IP
  }

  # Outbound internet access
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-internship-sg"
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "devops-internship-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "devops-internship-ec2-role"
  }
}

# IAM Policy for ECR access
resource "aws_iam_role_policy" "ecr_policy" {
  name = "devops-internship-ecr-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devops-internship-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "devops-internship-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "devops-internship-key"
  }
}

# User Data Script
locals {
  user_data = templatefile("${path.module}/user-data.sh", {
    ecr_repository_url = var.ecr_repository_url != "" ? var.ecr_repository_url : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/devops-internship/hello-world"
    aws_region        = var.aws_region
    docker_image_tag  = var.docker_image_tag
  })
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.deployer.key_name
  subnet_id             = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_server.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "devops-internship-app-server"
  }

  # Ensure instance is fully ready before considering deployment complete
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public
  ]
}

# Elastic IP (Optional - for static IP)
resource "aws_eip" "app_server" {
  count    = var.use_elastic_ip ? 1 : 0
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "devops-internship-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
