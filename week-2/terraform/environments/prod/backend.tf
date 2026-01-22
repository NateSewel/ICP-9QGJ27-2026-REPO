terraform {
  backend "s3" {
    bucket       = "terraform-state-nate247"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
