variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI for us-east-1"
  type        = string
  default     = "ami-0e2c8ccd4e1ffc351" # Canonical, Ubuntu, 24.04 LTS, amd64 noble image build on 2024-04-23
}

variable "app_sg_id" {
  description = "Security group ID of the application layer to allow access"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for pg_hba.conf"
  type        = string
}
