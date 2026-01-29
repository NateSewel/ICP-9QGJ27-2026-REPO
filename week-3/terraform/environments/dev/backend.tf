terraform {
  backend "s3" {
    bucket       = "terraform-state-dev-nate247"
    key          = "infrastructure/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Native S3 locking (Terraform 1.10+)
  }
}
