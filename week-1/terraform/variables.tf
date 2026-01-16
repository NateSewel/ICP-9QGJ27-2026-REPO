# Variables for Terraform Configuration
# InternCareer Path - Week 1

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # Free tier eligible
}

variable "ecr_repository_url" {
  description = "ECR repository URL for Docker image"
  type        = string
  default     = "" # Will be auto-populated if empty
}

variable "docker_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "use_elastic_ip" {
  description = "Whether to use Elastic IP for static IP address"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP for better security
}
