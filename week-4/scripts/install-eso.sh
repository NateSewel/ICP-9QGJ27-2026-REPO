#!/bin/bash
set -e

echo "Installing External Secrets Operator..."

# Add Helm repository
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install ESO
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set installCRDs=true

# Wait for ESO to be ready
echo "Waiting for External Secrets Operator to be ready..."
kubectl wait --for=condition=available deployment/external-secrets -n external-secrets --timeout=120s

# Apply the SecretStore and ExternalSecret manifests
# Note: You must ensure your K8s nodes have IAM permissions for Secrets Manager
kubectl apply -f k8s/security/external-secrets.yaml

echo "External Secrets Operator installed and configured!"
