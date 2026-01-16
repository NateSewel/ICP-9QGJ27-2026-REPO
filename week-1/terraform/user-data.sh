#!/bin/bash
# EC2 User Data Script - DevOps Internship Week 1
# This script runs on instance first boot to set up the application

set -e  # Exit on any error

# Log everything to a file
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "DevOps Internship - Week 1 Setup"
echo "Intern ID: ICP-9QGJ27-2026"
echo "Timestamp: $(date)"
echo "=========================================="

# Update system packages
echo "[1/6] Updating system packages..."
sudo yum update -y

# Install Docker
echo "[2/6] Installing Docker..."
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install AWS CLI v2 (if not already installed)
echo "[3/6] Checking AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
else
    echo "AWS CLI already installed: $(aws --version)"
fi

# Configure AWS region
echo "[4/6] Configuring AWS region..."
export AWS_DEFAULT_REGION=${aws_region}
aws configure set region ${aws_region}

# Login to ECR
echo "[5/6] Authenticating with ECR..."
aws ecr get-login-password --region ${aws_region} | \
    docker login --username AWS --password-stdin ${ecr_repository_url}

# Pull and run the Docker container
echo "[6/6] Pulling and running Docker container..."
docker pull ${ecr_repository_url}:${docker_image_tag}

# Stop and remove any existing container
docker stop hello-devops 2>/dev/null || true
docker rm hello-devops 2>/dev/null || true

# Run the container
docker run -d \
    --name hello-devops \
    --restart unless-stopped \
    -p 5000:5000 \
    -e ENVIRONMENT=production \
    -e AWS_REGION=${aws_region} \
    ${ecr_repository_url}:${docker_image_tag}

# Wait for container to be healthy
echo "Waiting for container to be healthy..."
sleep 10

# Check container status
if docker ps | grep -q hello-devops; then
    echo "Container is running successfully!"
    docker ps
    docker logs hello-devops
else
    echo "Container failed to start!"
    docker ps -a
    docker logs hello-devops
    exit 1
fi

# Test the application
echo "Testing application..."
sleep 5
RESPONSE=$(curl -s http://localhost:5000 || echo "failed")
if [[ $RESPONSE == *"Hello from DevOps Internship"* ]]; then
    echo "Application is responding correctly!"
    echo "Response: $RESPONSE"
else
    echo "Application might not be ready yet or failed to respond"
    echo "Response: $RESPONSE"
fi

# Create a cron job to check container health
echo "Setting up health check cron job..."
cat << 'CRON_SCRIPT' > /usr/local/bin/check-container-health.sh
#!/bin/bash
if ! docker ps | grep -q hello-devops; then
    echo "$(date): Container not running, restarting..." >> /var/log/container-health.log
    docker start hello-devops || docker run -d --name hello-devops --restart unless-stopped -p 5000:5000 -e ENVIRONMENT=production ${ecr_repository_url}:${docker_image_tag}
fi
CRON_SCRIPT

chmod +x /usr/local/bin/check-container-health.sh

# Add to crontab (check every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/check-container-health.sh") | crontab -

echo "=========================================="
echo "Setup complete!"
echo "Application should be accessible at:"
echo "http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000"
echo "=========================================="

# Print system information
echo "System Information:"
echo "- Hostname: $(hostname)"
echo "- OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "- Docker version: $(docker --version)"
echo "- Running containers:"
docker ps

echo "=========================================="
echo "Setup script completed at: $(date)"
echo "=========================================="