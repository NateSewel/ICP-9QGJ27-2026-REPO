terraform {
  required_version = ">= 1.14.0"
  
  backend "s3" {
    bucket       = "s3-kops-nate247-tfstate" # Separate bucket for TF state
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Native S3 locking (Terraform 1.11+)
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "s3-kops-nate247"
}

resource "aws_s3_bucket" "kops_state" {
  bucket         = var.bucket_name
  force_destroy  = true

  tags = {
    Name        = "KOps State Store"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "kops_state" {
  bucket = aws_s3_bucket.kops_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kops_state" {
  bucket = aws_s3_bucket.kops_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "kops_state_bucket" {
  value = aws_s3_bucket.kops_state.bucket
}
