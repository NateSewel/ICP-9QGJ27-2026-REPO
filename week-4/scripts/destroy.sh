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

echo "### Step 1: Deleting Kubernetes Cluster ###"
kops delete cluster --name=${CLUSTER_NAME} --state=${KOPS_STATE_STORE} --yes

echo "### Step 2: Emptying S3 State Store Bucket ###"
# Required because KOps leaves behind files that prevent Terraform from deleting the bucket
aws s3 rm ${KOPS_STATE_STORE} --recursive

echo "### Step 3: Destroying Infrastructure (S3 Bucket) ###"
cd infrastructure/terraform
terraform destroy -auto-approve
cd ../..

echo "### Step 4: Local Cleanup ###"
kubectl config delete-context ${CLUSTER_NAME} || echo "Context already removed"

echo "### SUCCESS: All infrastructure destroyed. ###"
