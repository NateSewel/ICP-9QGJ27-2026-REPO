#!/bin/bash
set -e

echo "Installing AWS Load Balancer Controller..."

# Prerequisites check: cert-manager
if ! kubectl get namespace cert-manager &> /dev/null; then
  echo "Installing cert-manager..."
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
  kubectl wait --for=condition=available deployment/cert-manager -n cert-manager --timeout=300s
fi

# Add Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
# Note: For KOps, you must manually attach the AWSLoadBalancerControllerIAMPolicy to your node IAM roles.
CLUSTER_NAME=${KOPS_CLUSTER_NAME:-"cluster.k8s.local"}

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller

echo "AWS Load Balancer Controller installed successfully!"
