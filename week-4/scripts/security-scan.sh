#!/bin/bash
set -e

echo "Running Security Scans..."

# 1. Container Image Scan (using Trivy)
if command -v trivy &> /dev/null; then
    echo "### Scanning Docker Image with Trivy ###"
    trivy image --severity HIGH,CRITICAL nate247/fastapi-kops:latest
else
    echo "Trivy not found. Skipping image scan."
fi

# 2. Kubernetes Manifest Scan (using Checkov or Kube-linter)
if command -v checkov &> /dev/null; then
    echo "### Scanning K8s Manifests with Checkov ###"
    checkov -d k8s/base
else
    echo "Checkov not found. Skipping manifest scan."
fi

# 3. Infrastructure Scan (Terraform)
if command -v tfsec &> /dev/null; then
    echo "### Scanning Terraform with tfsec ###"
    tfsec infrastructure/terraform
else
    echo "tfsec not found. Skipping terraform scan."
fi

echo "Security scans completed."
