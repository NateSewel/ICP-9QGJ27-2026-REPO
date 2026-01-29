# Security Policy

## Infrastructure Hardening

- **VPC Isolation**: All application and database resources are located in private subnets.
- **ALB Security**: The Application Load Balancer is the only component exposed to the public internet.
- **Least Privilege**: Security groups only allow traffic on necessary ports (e.g., 80 for ALB, 8080 for App, 5432 for DB).
- **Encryption**:
  - **S3 State**: Encrypted via AES-256.
  - **RDS**: Storage encryption enabled.
  - **SQS**: Server-side encryption enabled.
  - **Redis**: Transit encryption recommended for production (currently single-node dev).

## Secret Management
- **NO SECRETS IN CODE**: Use the provided `terraform.tfvars` with caution. In production, use **HashiCorp Vault** or **AWS Secrets Manager**.
- **SOPS Integration**: For team collaboration, it is recommended to use **SOPS** to encrypt `.tfvars` files.

## Vulnerability Scanning
The `.github/workflows/security-scan.yml` runs **Trivy** and **tfsec** on every pull request to detect misconfigurations and vulnerabilities.
