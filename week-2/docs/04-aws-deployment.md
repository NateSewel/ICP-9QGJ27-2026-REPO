# AWS Deployment

## Infrastructure

The infrastructure is managed via Terraform and includes:

- **VPC**: 10.0.0.0/16 with 2 Public and 2 Private subnets.
- **ALB**: Handles incoming HTTP traffic and distributes it to the ASG.
- **ASG**: Manages a fleet of EC2 instances running the Dockerized API.
- **EC2 (DB)**: A single instance running PostgreSQL in a private subnet.
- **ECR**: Private registry for application images.

## Terraform Backend

The state is stored in an S3 bucket with native locking enabled (Terraform 1.11+).

## CI/CD Pipeline

The deployment process is automated using GitHub Actions:

1. **Test**: Runs on every push/PR.
2. **Infrastructure**: 
   - Runs `terraform plan` on push to `main`.
   - Runs `terraform apply` on successful plan.
3. **Deployment**:
   - Builds the Docker image.
   - Pushes to Amazon ECR.
   - (Note: Real-world rolling updates would be handled via ECS or Kubernetes; for this task, the ASG pulls the latest image).

## Manual Steps

1. Create the S3 bucket for Terraform state: `terraform-state-nate247`.
2. Configure GitHub Secrets:
   - `AWS_ROLE_ARN`: OIDC Role for GitHub Actions.
   - `JWT_SECRET`: Secret for application tokens.
