#!/bin/bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

export REGION="us-east-1"
export BUCKET_NAME="s3-kops-nate247"
export CLUSTER_NAME="cluster.k8s.local"
export KOPS_STATE_STORE="s3://${BUCKET_NAME}"
export DOCKER_USERNAME="nate247"

echo "### Step 1: Provision Infrastructure (S3 Bucket) ###"
cd infrastructure/terraform
terraform init
terraform apply -auto-approve
cd ../..

echo "### Step 2: Build & Push Docker Image ###"
cd app
docker build -t ${DOCKER_USERNAME}/fastapi-kops:latest .
docker push ${DOCKER_USERNAME}/fastapi-kops:latest
cd ..

echo "### Step 3: Create KOps Cluster Configuration ###"
# Note: Gossip DNS is automatically enabled for names ending in .k8s.local
kops create cluster \
    --name=${CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --zones=${REGION}a \
    --node-count=1 \
    --node-size=t3.micro \
    --control-plane-size=t3.small \
    --ssh-public-key=~/ \
    --yes

echo "### Step 4: Validate Cluster ###"
echo "Waiting for cluster to be ready (this can take 5-10 minutes)..."
kops validate cluster --wait 10m

echo "### Step 5: Export Configuration Locally ###"
mkdir -p infrastructure/kops
kops get cluster --name=${CLUSTER_NAME} --state=${KOPS_STATE_STORE} -o yaml > infrastructure/kops/cluster.yaml
kops get ig --name=${CLUSTER_NAME} --state=${KOPS_STATE_STORE} -o yaml > infrastructure/kops/instancegroups.yaml

echo "### Step 6: Deploy Application ###"
kubectl apply -k k8s/base

echo "### Step 7: Install Monitoring Stack ###"
bash scripts/install-monitoring.sh

echo "### Step 8: Install External Secrets Operator ###"
bash scripts/install-eso.sh

echo "### Step 9: Install AWS Load Balancer Controller ###"
bash scripts/install-lbc.sh

echo "### Step 6: Verify Deployment ###"
kubectl get pods -n curadocs
kubectl get svc -n curadocs
