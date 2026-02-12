# Full Project Deployment Guide (KOps & FastAPI)

This guide provides a step-by-step walkthrough for deploying the production-grade FastAPI application onto a Kubernetes cluster managed by KOps on AWS.

---

## Prerequisites

Ensure the following tools are installed on your local machine:
- **AWS CLI v2**
- **KOps v1.28+**
- **kubectl v1.28+**
- **Terraform v1.11+**
- **Helm v3**
- **Docker**

---

## Environment Variables

To reuse this project, export these variables in your terminal (or add them to your `~/.bashrc` or `~/.zshrc`):

```bash
# AWS Configuration
export AWS_REGION="us-east-1"
export AWS_PROFILE="default" # Or your specific profile

# KOps Configuration
export CLUSTER_NAME="cluster.k8s.local"
export BUCKET_NAME="s3-kops-nate247" # The bucket created via Terraform
export KOPS_STATE_STORE="s3://${BUCKET_NAME}"

# Docker Configuration
export DOCKER_USERNAME="nate247"
export ECR_REPOSITORY="fastapi-app"
```

---

## Step-by-Step Deployment

### Step 1: Provision Infrastructure State Store
Before KOps can run, it needs an S3 bucket to store the cluster state.
```bash
cd infrastructure/terraform
terraform init
terraform apply -auto-approve
cd ../..
```

### Step 2: Build and Push the Application
Build your optimized FastAPI image and push it to your registry (Docker Hub or ECR).
```bash
cd app
docker build -t ${DOCKER_USERNAME}/fastapi-kops:latest .
docker push ${DOCKER_USERNAME}/fastapi-kops:latest
cd ..
```

### Step 3: Create the Kubernetes Cluster
Use KOps to generate the cluster configuration and provision resources.
```bash
# Create cluster configuration
kops create cluster \
    --name=${CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --zones=${AWS_REGION}a \
    --node-count=2 \
    --node-size=t3.medium \
    --control-plane-size=t3.medium \
    --yes

# Wait for cluster to be ready (usually 5-10 minutes)
kops validate cluster --wait 10m
```

### Step 4: Install Controllers (Secrets & Ingress)
Install the essential platform components using the provided scripts.
```bash
# Install Monitoring (Prometheus/Grafana)
bash scripts/install-monitoring.sh

# Install External Secrets Operator
bash scripts/install-eso.sh

# Install AWS Load Balancer Controller
bash scripts/install-lbc.sh
```

### Step 5: Deploy the Application
Deploy the namespace, deployment, and networking rules using Kustomize.
```bash
kubectl apply -k k8s/base
```

---

## Post-Deployment Verification

### Check Pod Status
```bash
kubectl get pods -n curadocs
```

### Accessing the Application
1. Get the Ingress URL:
   ```bash
   kubectl get ingress -n curadocs
   ```
2. Visit the `/health` endpoint in your browser.

### Monitoring
1. Get the Grafana LoadBalancer URL:
   ```bash
   kubectl get svc -n monitoring
   ```
2. Login with `admin / prom-operator`.

---

## Cleanup
To avoid AWS costs, destroy all resources when finished:
```bash
bash scripts/destroy.sh
```

---

## Important Security Notes
- **Secrets Manager**: Create a secret in AWS Secrets Manager named `prod/fastapi/db-url` for the External Secrets Operator to sync.
- **IAM**: Ensure your EC2 Node Instance Profile has the necessary permissions for **Secrets Manager** and **Elastic Load Balancing**.
