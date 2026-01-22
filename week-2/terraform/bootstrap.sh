#!/bin/bash

# Configuration
BUCKET_NAME="terraform-state-nate247"
REGION="us-east-1"

echo "Starting bootstrap for S3 Backend: $BUCKET_NAME"

# 1. Create S3 Bucket
echo "Creating bucket..."
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION"

# 2. Enable Versioning (Crucial for state history)
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# 3. Enable Default Encryption (AES256)
echo "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# 4. Block All Public Access (Security Hardening)
echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

echo "Bootstrap complete! You can now run 'terraform init'."
