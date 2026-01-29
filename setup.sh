#!/bin/bash
# Repository Setup Script
# InternCareer Path - DevOps Internship
# Intern ID: ICP-9QGJ27-2026

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     DevOps Internship Repository Setup                         ║"
echo "║     InternCareer Path - ICP-9QGJ27-2026                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git first."
    exit 1
fi

print_success "Git is installed"

# Create main repository directory
REPO_NAME="ICP-9QGJ27-2026-REPO"

if [ -d "$REPO_NAME" ]; then
    print_warning "Directory $REPO_NAME already exists!"
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    mkdir -p $REPO_NAME
    print_success "Created repository directory: $REPO_NAME"
fi

cd $REPO_NAME

# Initialize Git repository
if [ ! -d ".git" ]; then
    git init
    print_success "Initialized Git repository"
else
    print_info "Git repository already initialized"
fi

# Create .gitignore
print_info "Creating .gitignore..."
cat > .gitignore << 'EOF'
# Terraform
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform/
.terraform.lock.hcl
terraform.tfvars

# AWS
*.pem
.aws/
aws-credentials.txt

# Docker
*.log

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
*.bak

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.env

# Node
node_modules/
npm-debug.log
yarn-error.log

# Secrets
secrets/
*.secret
credentials.json
EOF

print_success "Created .gitignore"

# Create directory structure for Week 1
print_info "Creating Week 1 directory structure..."

mkdir -p week-1/{docs,hello-world-app,terraform,screenshots}
mkdir -p .github/workflows

print_success "Created directory structure"

# Create placeholder files
print_info "Creating placeholder files..."

# Week 1 README
cat > week-1/README.md << 'EOF'
# Week 1: Foundation & Setup

This directory will contain all Week 1 deliverables.

## Contents
- `docs/` - Documentation and guides
- `hello-world-app/` - Docker application
- `terraform/` - Infrastructure as Code
- `screenshots/` - Deployment evidence

See the main README.md for detailed information.
EOF

# Application README
cat > week-1/hello-world-app/README.md << 'EOF'
# Hello World DevOps Application

## Description
A simple Flask-based web application demonstrating containerization and cloud deployment.

## Quick Start

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run application
python app.py
```

### Docker
```bash
# Build image
docker build -t hello-devops:v1.0 .

# Run container
docker run -p 8080:5000 hello-devops:v1.0
```

See the documentation in `docs/` for detailed instructions.
EOF

# Terraform README
cat > week-1/terraform/README.md << 'EOF'
# Terraform Infrastructure

## Description
Infrastructure as Code for deploying the Hello World application to AWS.

## Usage

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

**Important:** Update variables in `terraform.tfvars` before applying.

See the documentation for detailed deployment instructions.
EOF

# Requirements.txt
cat > week-1/hello-world-app/requirements.txt << 'EOF'
Flask==3.0.0
gunicorn==21.2.0
EOF

# .dockerignore
cat > week-1/hello-world-app/.dockerignore << 'EOF'
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.git
.gitignore
README.md
.dockerignore
*.md
.env
EOF

# Create screenshots placeholder
touch week-1/screenshots/.gitkeep

print_success "Created placeholder files"

# Create main README
print_info "Creating main README.md..."
cat > README.md << 'EOF'
# DevOps Internship - InternCareer Path

**Intern ID:** ICP-9QGJ27-2026  
**Repository ID:** ICP-9QGJ27-2026-REPO  
**Duration:** 6 Weeks

## About This Repository

This repository contains all weekly tasks and projects for the DevOps internship program at InternCareer Path.

## Structure

- `week-1/` - Foundation & Setup
- `week-2/` - Core Concepts
- `week-3/` - Intermediate Integration
- `week-4/` - Advanced Features
- `week-5/` - Production Readiness
- `week-6/` - Capstone Project

##  Quick Links

- [Week 1 Documentation](week-1/README.md)
- [GitHub Actions](.github/workflows/)

##  Contact

**Nathaniel Isewede**
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)
- Email: nathanielisewede@example.com

#InternCareerPath #DevOps
EOF

print_success "Created main README.md"

# Initial commit
print_info "Creating initial commit..."
git add .
git commit -m "Initial commit: Repository structure setup

- Added .gitignore
- Created week-1 directory structure
- Added placeholder files and READMEs
- Initialized repository for DevOps Internship
- Intern ID: ICP-9QGJ27-2026"

print_success "Created initial commit"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  Setup Complete!                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
print_info "Repository structure created successfully!"
echo ""
echo " Directory: $(pwd)"
echo ""
echo "Next steps:"
echo "1. Create a new repository on GitHub named 'ICP-9QGJ27-2026-REPO'"
echo "2. Run these commands:"
echo "   ${BLUE}git remote add origin https://github.com/yourusername/ICP-9QGJ27-2026-REPO.git${NC}"
echo "   ${BLUE}git branch -M main${NC}"
echo "   ${BLUE}git push -u origin main${NC}"
echo ""
echo "3. Add your actual code files to the appropriate directories"
echo "4. Update README.md files with your information"
echo "5. Complete Week 1 tasks following the documentation"
echo ""
print_success "Happy coding!"
echo ""
echo "#InternCareerPath #DevOps"
