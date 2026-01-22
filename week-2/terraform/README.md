# Terraform Infrastructure

This directory contains the Infrastructure as Code (IaC) to deploy the User Management System to AWS.

## Prerequisites

- **Terraform**: v1.14.3 or higher.
- **AWS CLI**: Configured with appropriate credentials.
- **S3 Bucket**: Required for state storage (can be created using `bootstrap.sh`).

## Directory Structure

- `bootstrap.sh`: Script to create and harden the S3 backend bucket.
- `cleanup-backend.sh`: Script to remove the S3 backend bucket after infrastructure is destroyed.
- `environments/prod`: Production environment configuration and state backend.
- `modules/vpc`: Networking layer (VPC, Subnets, IGW, NAT).
- `modules/compute`: Application layer (ALB, ASG, Security Groups).
- `modules/database`: Persistence layer (Self-managed PostgreSQL on EC2).
- `modules/registry`: Container registry (ECR).

## Resource Inventory

The production deployment provisions a total of **3 EC2 instances**:
- **2x Application Instances**: Managed by an Auto Scaling Group (ASG) for high availability.
- **1x Database Instance**: A standalone instance running PostgreSQL.

## Deployment Steps

### 0. Bootstrap (One-time setup)
If the S3 backend bucket does not exist, run the bootstrap script from the `terraform` root:
```bash
bash bootstrap.sh
```

### 1. Initialize
Navigate to the production environment and initialize Terraform.
```bash
cd environments/prod
terraform init
```

### 2. Plan
Generate and review an execution plan.
```bash
terraform plan
```

### 3. Apply
Deploy the infrastructure to AWS.
```bash
terraform apply
```

## State Management

The project uses an S3 backend with native locking (introduced in Terraform 1.11).

```hcl
backend "s3" {
  bucket       = "terraform-state-nate247"
  key          = "prod/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

## Cleanup

### 1. Destroy Infrastructure
To remove all AWS resources managed by Terraform:
```bash
cd environments/prod
terraform destroy
```

### 2. Remove Backend (Optional)
To completely wipe the S3 state bucket:
```bash
cd ../..
bash cleanup-backend.sh
```
