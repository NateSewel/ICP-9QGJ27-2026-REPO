variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the Vault instance will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the Vault instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
