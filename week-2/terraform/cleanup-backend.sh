#!/bin/bash

# Configuration
BUCKET_NAME="terraform-state-nate247"

echo "WARNING: This will permanently delete the Terraform state bucket: $BUCKET_NAME"
read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

echo "Emptying bucket (including all versions and delete markers)..."

# Remove all object versions
aws s3api delete-objects \
    --bucket "$BUCKET_NAME" \
    --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1

# Remove all delete markers
aws s3api delete-objects \
    --bucket "$BUCKET_NAME" \
    --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1

echo "Deleting the bucket..."
aws s3 rb "s3://$BUCKET_NAME" --force

echo "Cleanup complete! The S3 backend has been removed."
