# Architecture Documentation

## Overview
This project implements a production-ready FastAPI application deployed on AWS using Kubernetes (KOps).

## Components

### 1. Cloud Infrastructure (AWS)
- **VPC**: Isolated network for the cluster.
- **S3**: Used for KOps state store and Terraform state.
- **ECR**: Elastic Container Registry for application images.
- **ALB**: Application Load Balancer managed by the AWS Load Balancer Controller.
- **Secrets Manager**: Centralized secrets storage.

### 2. Kubernetes Cluster (KOps)
- Managed via KOps for full control over the control plane and worker nodes.
- **Auto-scaling**: Cluster autoscaler (optional) and HPA for pods.

### 3. Application (FastAPI)
- **Optimized Python 3.12 image**.
- **Structured JSON logging**.
- **Prometheus instrumentation**.
- **Non-root execution** for security.

### 4. Observability
- **Prometheus**: Metrics collection.
- **Grafana**: Dashboard visualization.
- **PodMonitors**: For automatic discovery of application metrics.

### 5. Security
- **Network Policies**: Zero-trust traffic isolation.
- **External Secrets Operator**: Syncing secrets from AWS Secrets Manager.
- **Pod Security Standards**: Restricted profile enforced on the `curadocs` namespace.
- **RBAC**: Least privilege access for service accounts.
