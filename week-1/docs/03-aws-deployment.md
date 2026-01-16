# AWS Deployment Guide

## 🎯 Objective
Deploy the containerized Hello World application to AWS using ECR (Elastic Container Registry) and EC2, automated with Terraform.

## 🏗️ Architecture Overview

```
Developer → GitHub → Docker Build → AWS ECR → AWS EC2 (Docker Container)
                                              ↓
                                        Security Group (Port 5000)
```

## 📋 Prerequisites

- AWS CLI configured with credentials
- Docker installed and running
- Terraform installed
- Hello World application built locally

## 🚀 Deployment Steps

### Part 1: Push Docker Image to AWS ECR

#### Step 1: Create ECR Repository
```bash
# Create ECR repository
aws ecr create-repository \
    --repository-name devops-internship/hello-world \
    --region us-east-1

# Expected output will include repositoryUri
# Example: 123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-internship/hello-world
```

#### Step 2: Authenticate Docker to ECR
```bash
# Get authentication token and login
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    123456789012.dkr.ecr.us-east-1.amazonaws.com

# Replace 123456789012 with your AWS account ID
# Find your account ID:
aws sts get-caller-identity --query Account --output text
```

#### Step 3: Tag and Push Image
```bash
# Get your ECR repository URI
ECR_URI=$(aws ecr describe-repositories \
    --repository-names devops-internship/hello-world \
    --region us-east-1 \
    --query 'repositories[0].repositoryUri' \
    --output text)

echo $ECR_URI

# Tag your local image
docker tag hello-devops:v1.0 $ECR_URI:v1.0
docker tag hello-devops:v1.0 $ECR_URI:latest

# Push to ECR
docker push $ECR_URI:v1.0
docker push $ECR_URI:latest

# Verify image in ECR
aws ecr list-images \
    --repository-name devops-internship/hello-world \
    --region us-east-1
```

### Part 2: Deploy with Terraform

#### Step 1: Prepare Terraform Files

Navigate to the terraform directory:
```bash
cd terraform
```

The terraform configuration consists of:
- `main.tf` - Main infrastructure code
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `user-data.sh` - EC2 initialization script

#### Step 2: Initialize Terraform
```bash
# Initialize Terraform (downloads providers)
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt
```

#### Step 3: Plan Deployment
```bash
# Create execution plan
terraform plan

# Save plan to file (optional)
terraform plan -out=tfplan
```

Review the plan carefully. It should show:
- VPC and subnet creation
- Security group with port 5000 open
- EC2 instance with Docker installed
- IAM role for ECR access

#### Step 4: Apply Configuration
```bash
# Apply the configuration
terraform apply

# Type 'yes' when prompted

# Or apply with auto-approve (use with caution)
terraform apply -auto-approve
```

Wait for Terraform to complete (typically 2-5 minutes).

#### Step 5: Get Outputs
```bash
# View all outputs
terraform output

# Get specific output
terraform output instance_public_ip
terraform output application_url
```

### Part 3: Verify Deployment

#### Access Your Application
```bash
# Get the application URL
APP_URL=$(terraform output -raw application_url)

# Wait 2-3 minutes for EC2 to fully initialize

# Test the application
curl $APP_URL

# Test health endpoint
curl $APP_URL/health
```

#### Check EC2 Instance
```bash
# Get instance ID
INSTANCE_ID=$(terraform output -raw instance_id)

# View instance details
aws ec2 describe-instances --instance-ids $INSTANCE_ID

# Get system log
aws ec2 get-console-output --instance-id $INSTANCE_ID
```

#### SSH into EC2 (Optional)
```bash
# Download the SSH key from Terraform output
terraform output -raw private_key > devops-key.pem
chmod 400 devops-key.pem

# SSH into instance
ssh -i devops-key.pem ec2-user@$(terraform output -raw instance_public_ip)

# Once connected, check Docker
sudo docker ps
sudo docker logs $(sudo docker ps -q)

# Exit
exit
```

## 🔒 Security Configuration

### Security Group Rules
The Terraform configuration creates a security group with:
- **Inbound:**
  - Port 5000 (HTTP) - Application access
  - Port 22 (SSH) - Management access
- **Outbound:**
  - All traffic allowed (for downloading Docker images)

### IAM Role
EC2 instance has an IAM role with permissions to:
- Pull images from ECR
- Write CloudWatch logs

## 📊 Monitoring

### CloudWatch Logs
```bash
# View log groups
aws logs describe-log-groups --log-group-name-prefix /devops-internship

# Tail logs (if configured)
aws logs tail /devops-internship/hello-world --follow
```

### EC2 Metrics
```bash
# Get CPU utilization
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=$INSTANCE_ID \
    --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

## 🧹 Cleanup Resources

**IMPORTANT:** Always destroy resources when done to avoid AWS charges!

```bash
# Destroy all resources
terraform destroy

# Type 'yes' when prompted

# Verify everything is deleted
terraform show
```

### Manual Cleanup (if needed)
```bash
# Delete ECR images
aws ecr batch-delete-image \
    --repository-name devops-internship/hello-world \
    --image-ids imageTag=v1.0 imageTag=latest

# Delete ECR repository
aws ecr delete-repository \
    --repository-name devops-internship/hello-world \
    --force
```

## 🐛 Troubleshooting

### Application Not Accessible
```bash
# 1. Check security group
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id)

# 2. Check instance status
aws ec2 describe-instance-status --instance-ids $(terraform output -raw instance_id)

# 3. Check user-data execution
ssh -i devops-key.pem ec2-user@$(terraform output -raw instance_public_ip)
sudo cat /var/log/cloud-init-output.log
```

### Docker Container Not Running
```bash
# SSH into instance
ssh -i devops-key.pem ec2-user@$(terraform output -raw instance_public_ip)

# Check Docker service
sudo systemctl status docker

# Check containers
sudo docker ps -a

# Check logs
sudo docker logs $(sudo docker ps -aq)
```

### Terraform Errors

#### State Lock Error
```bash
# If state is locked (rare)
terraform force-unlock <LOCK_ID>
```

#### Resource Already Exists
```bash
# Import existing resource
terraform import aws_instance.app_server <instance-id>

# Or destroy and recreate
terraform destroy -target=aws_instance.app_server
terraform apply
```

### ECR Authentication Issues
```bash
# Re-authenticate
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

# Verify credentials
aws ecr describe-repositories
```

## 💰 Cost Optimization

### Estimated Monthly Costs (Free Tier)
- **EC2 t2.micro:** $0 (750 hours/month free tier)
- **ECR Storage:** $0 for first 500MB/month
- **Data Transfer:** $0 for first 1GB/month

**Total:** $0 with free tier, ~$8-10/month without

### Cost Saving Tips
1. Always destroy resources when not in use
2. Use t2.micro (free tier eligible)
3. Delete old ECR images
4. Stop instances instead of terminating (if needed temporarily)

```bash
# Stop instance (saves compute costs)
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)

# Start instance
aws ec2 start-instances --instance-ids $(terraform output -raw instance_id)
```

## ✅ Verification Checklist

- [ ] ECR repository created
- [ ] Docker image pushed to ECR
- [ ] Terraform initialized successfully
- [ ] Infrastructure deployed without errors
- [ ] Application accessible via public IP
- [ ] Health check endpoint responding
- [ ] EC2 instance running correctly
- [ ] Security groups configured properly
- [ ] Screenshots captured
- [ ] Resources cleaned up after testing

## 📸 Screenshots to Capture

1. ECR repository with pushed images
2. Terraform apply output
3. EC2 instance in AWS console
4. Application running in browser (with public IP visible)
5. `curl` output showing successful response
6. EC2 instance details showing running containers

## 📚 Additional Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker on EC2](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html)

## 🎯 What You Learned

1. **Container Registry:** How to use AWS ECR to store Docker images
2. **Infrastructure as Code:** Automating AWS resource creation with Terraform
3. **Cloud Deployment:** Deploying containerized applications to EC2
4. **Security:** Configuring security groups and IAM roles
5. **Monitoring:** Basic AWS monitoring and logging

---

**Status:** ✅ Completed  
**Previous:** [← Docker Basics](02-docker-basics.md)  
**Next:** Week 2 - Core Concepts

**🎉 Congratulations!** You've completed Week 1 of the DevOps Internship!
