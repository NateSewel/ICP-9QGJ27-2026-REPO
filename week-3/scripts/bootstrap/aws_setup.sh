#!/bin/bash
# Bootstrap script to create Terraform backend resources

REGION="us-east-1"
BUCKET_NAME="terraform-state-dev-nate247"

# Create S3 Bucket
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION

# Enable Versioning
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable Encryption
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block Public Access
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

echo "Bootstrap complete. S3 bucket $BUCKET_NAME created."
