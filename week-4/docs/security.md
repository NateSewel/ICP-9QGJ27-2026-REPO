# Security Hardening Guide

## Container Security
- **Base Image**: Using `python:3.12-slim` to reduce attack surface.
- **Non-Root User**: Application runs as user `10001`.
- **Read-Only Filesystem**: Enforced in Kubernetes deployment with `readOnlyRootFilesystem: true`.
- **Capabilities**: All Linux capabilities are dropped (`drop: ["ALL"]`).

## Kubernetes Security
- **Namespace Isolation**: Using `curadocs` namespace for application workloads.
- **Pod Security Standards**: Enforcing the `restricted` profile via labels.
- **Network Policies**: 
  - Default deny all ingress/egress.
  - Explicit allow for ALB to FastAPI.
  - Explicit allow for Prometheus scraping.
- **RBAC**: Dedicated `ServiceAccounts` for application and monitoring with minimal permissions.

## Secrets Management
- **AWS Secrets Manager**: Single source of truth for sensitive data.
- **External Secrets Operator**: Periodically fetches secrets from AWS and injects them as Kubernetes Secrets.

## Infrastructure Security
- **S3 Encryption**: KOps state store is encrypted with AES256.
- **Private Subnets**: (Recommended) Nodes should reside in private subnets with NAT gateways.
- **Security Groups**: Minimal inbound rules, typically only allowing 80/443 for the ALB.
