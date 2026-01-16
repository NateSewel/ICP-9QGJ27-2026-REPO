# Environment Setup Guide

## Objective
Set up a complete DevOps development environment with all necessary tools and configurations.

## Tools to Install

### 1. Git & GitHub Setup

#### Install Git
**Windows:**
```bash
# Download from https://git-scm.com/download/win
# Or use winget
winget install --id Git.Git -e --source winget
```

**macOS:**
```bash
# Using Homebrew
brew install git
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install git -y
```

#### Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

#### Verify Installation
```bash
git --version
# Expected output: git version 2.x.x
```

### 2. Docker Installation

#### Windows
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Enable WSL 2 if prompted
4. Restart your computer

#### macOS
```bash
# Using Homebrew
brew install --cask docker
```

#### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Add your user to docker group
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### Verify Installation
```bash
docker --version
docker run hello-world
```

### 3. AWS CLI Installation

#### Windows
```powershell
# Download and run the MSI installer
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### macOS
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### Configure AWS CLI
```bash
aws configure
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

#### Verify Installation
```bash
aws --version
aws sts get-caller-identity
```

### 4. Terraform Installation

#### Windows
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

#### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Linux
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update
sudo apt install terraform -y
```

#### Verify Installation
```bash
terraform --version
```

### 5. Visual Studio Code (Recommended IDE)

#### All Platforms
Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)

#### Recommended Extensions
- Docker
- Terraform
- AWS Toolkit
- GitLens
- YAML
- Python (if using Python)

Install extensions:
```bash
code --install-extension ms-azuretools.vscode-docker
code --install-extension hashicorp.terraform
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension eamodio.gitlens
code --install-extension redhat.vscode-yaml
```

### 6. Python (Optional - for Hello World App)

#### Windows
Download from [https://www.python.org/downloads/](https://www.python.org/downloads/)

#### macOS/Linux
```bash
# macOS
brew install python3

# Linux
sudo apt install python3 python3-pip -y
```

#### Verify Installation
```bash
python3 --version
pip3 --version
```

## AWS Account Setup

### Create AWS Free Tier Account
1. Go to [https://aws.amazon.com/free/](https://aws.amazon.com/free/)
2. Click "Create a Free Account"
3. Follow the registration process
4. Verify your identity and payment method

### Create IAM User for Development
1. Sign in to AWS Console
2. Navigate to IAM (Identity and Access Management)
3. Click "Users" → "Add users"
4. User name: `devops-intern`
5. Select "Access key - Programmatic access"
6. Attach policies:
   - AmazonEC2FullAccess
   - AmazonECRFullAccess
   - IAMFullAccess (for Terraform)
7. Save the Access Key ID and Secret Access Key

### Security Best Practices
```bash
# Never commit AWS credentials to Git
echo ".aws/" >> ~/.gitignore
echo "*.pem" >> ~/.gitignore
echo "terraform.tfstate*" >> ~/.gitignore
```

## Create Project Repository

### Initialize Repository
```bash
# Create project directory
mkdir ICP-9QGJ27-2026-REPO
cd ICP-9QGJ27-2026-REPO

# Initialize Git
git init

# Create .gitignore
cat > .gitignore << EOF
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# AWS
*.pem
.aws/

# Docker
*.log

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
.env
venv/
EOF

# Create initial commit
git add .gitignore
git commit -m "Initial commit: Add .gitignore"
```

### Create Repository on GitHub
1. Go to [https://github.com/new](https://github.com/new)
2. Repository name: `ICP-9QGJ27-2026-REPO`
3. Description: "DevOps Internship - InternCareer Path"
4. Select "Public"
5. Click "Create repository"

### Push to GitHub
```bash
git remote add origin https://github.com/yourusername/ICP-9QGJ27-2026-REPO.git
git branch -M main
git push -u origin main
```

## Verification Checklist

- [ ] Git installed and configured
- [ ] Docker installed and running
- [ ] AWS CLI installed and configured
- [ ] Terraform installed
- [ ] VS Code installed with extensions
- [ ] AWS account created
- [ ] IAM user created with proper permissions
- [ ] GitHub repository created and initialized
- [ ] All credentials secured (not in Git)

## Next Steps
Once all tools are installed and verified, proceed to [02-docker-basics.md](02-docker-basics.md) to build your first containerized application.

## Troubleshooting

### Docker Won't Start
- **Windows:** Enable virtualization in BIOS
- **Linux:** Check if user is in docker group: `groups $USER`
- Restart Docker service: `sudo systemctl restart docker`

### AWS CLI Configuration Issues
```bash
# Check current configuration
aws configure list

# Reconfigure if needed
aws configure
```

### Terraform Command Not Found
```bash
# Verify PATH
echo $PATH

# Reinstall or add to PATH manually
```

---

**Status:** Completed  
**Next:** [Docker Basics →](02-docker-basics.md)
