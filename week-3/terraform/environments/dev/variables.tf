variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_name" {
  type    = string
  default = "myappdb"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "MicroservicesPlatform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
