variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "instance_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
