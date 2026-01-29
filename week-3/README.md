# Microservices Integration Platform Infrastructure

This repository contains the Terraform infrastructure for a production-grade Microservices Integration Platform on AWS.

## Architecture

- **Compute**: Amazon EC2 (Manual Scaling for Dev)
- **Networking**: VPC with Public/Private Subnets
- **Load Balancing**: Application Load Balancer (ALB)
- **Database**: Amazon RDS (PostgreSQL 16)
- **Caching**: Amazon ElastiCache (Redis 7)
- **Messaging**: Amazon SQS
- **Security**: HashiCorp Vault for Secrets Management

## Prerequisites

- **Terraform >= 1.14.0**
- **AWS CLI** configured with appropriate credentials
- **S3 Bucket** created for remote state storage (Update `backend.tf` accordingly)
- **Git** for repository management

---

## Step-by-Step Setup Guide

### 0. Initial Setup (S3 Backend)

Before deploying the infrastructure, you must create the S3 bucket used for Terraform state storage:

1.  **Run the Bootstrap Script**:
    ```bash
    ./scripts/bootstrap/aws_setup.sh
    ```
    *This script creates the S3 bucket, enables versioning, and configures server-side encryption.*

### 1. Infrastructure Deployment

Follow these steps to provision the AWS resources:

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd week-3
    ```

2.  **Navigate to the Dev Environment**:
    ```bash
    cd terraform/environments/dev
    ```

3.  **Configure the Backend**:
    Edit `backend.tf` to ensure the `bucket` and `region` match your existing S3 bucket.
    *Note: Native S3 locking is enabled via `use_lockfile = true` (Terraform 1.10+).*

4.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

5.  **Review the Plan**:
    Check what resources will be created:
    ```bash
    terraform plan
    ```

6.  **Apply the Infrastructure**:
    Deploy the resources to AWS:
    ```bash
    terraform apply -auto-approve
    ```
    *This will take approximately 10-15 minutes due to RDS and ElastiCache provisioning.*

---

### 2. Application Deployment & Verification

The Employee Management System (Node.js/Express) is automatically deployed via EC2 `user_data`.

1.  **Retrieve the ALB DNS Name**:
    After the apply completes, look for the `alb_dns_name` output:
    ```bash
    terraform output alb_dns_name
    ```

2.  **Verify Application Connectivity**:
    The application runs on port 3000 but is exposed via the ALB on port 80.
    Open your browser and navigate to:
    `http://<alb_dns_name>/`

3.  **Test the API Endpoints**:
    - **Health Check**: `GET http://<alb_dns_name>/`
    - **List Employees**: `GET http://<alb_dns_name>/employees`
    - **Add Employee**:
      ```bash
      curl -X POST http://<alb_dns_name>/employees \
        -H "Content-Type: application/json" \
        -d '{"name": "Jane Doe", "role": "Senior Engineer"}'
      ```

---

### 3. Post-Deployment: Vault Configuration

HashiCorp Vault is deployed on a dedicated EC2 instance for secrets management.

1.  **Retrieve Vault Public IP/DNS**:
    Find the Vault instance in your AWS Console (it's in the private subnet, accessible via SSM or Bastion if configured).

2.  **Initialize & Unseal**:
    Follow the detailed steps in [docs/OPERATIONS.md](docs/OPERATIONS.md) to initialize the Vault operator and unseal the vault.

---

### 4. Maintenance & Operations

- **Scaling**: Update `instance_count` in `variables.tf` or `terraform.tfvars` and run `terraform apply`.
- **Logs**: Application logs are local to the EC2 instances in `/app`.
- **Secrets**: Rotate database passwords in `terraform.tfvars` and re-apply.

---

### 5. Cleanup

To avoid ongoing AWS costs, follow these steps to completely remove the project:

1.  **Destroy Terraform Infrastructure**:
    ```bash
    cd terraform/environments/dev
    terraform destroy -auto-approve
    ```

2.  **Destroy the S3 Backend Bucket**:
    *Warning: This will delete all Terraform state history.*
    ```bash
    cd ../../../
    ./scripts/bootstrap/cleanup_s3.sh
    ```

---

## Security Policy

- **Encryption**: All data at rest (EBS, RDS, S3) is encrypted using AWS-managed keys.
- **Network**: Private subnets isolate the Database and Application layers from direct internet access.
- **Secrets**: Database credentials are marked as `sensitive` and should be managed via Vault in production.

For more details, see [docs/SECURITY.md](docs/SECURITY.md).
