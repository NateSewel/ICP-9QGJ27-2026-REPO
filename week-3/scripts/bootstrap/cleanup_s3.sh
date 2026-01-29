#!/bin/bash
# Script to delete Terraform backend S3 bucket and its contents (including versions)

REGION="us-east-1"
BUCKET_NAME="terraform-state-dev-nate247"

echo "Starting cleanup for bucket: $BUCKET_NAME in region: $REGION"

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Bucket exists. Emptying contents..."

    # Delete all versions
    echo "Deleting all object versions..."
    aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > versions.json
    # Check if the file contains actual objects (not just "Objects: null")
    if grep -q "\"Key\"" versions.json; then
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete file://versions.json
    fi
    rm versions.json

    # Delete all delete markers
    echo "Deleting all delete markers..."
    aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > markers.json
    if grep -q "\"Key\"" markers.json; then
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete file://markers.json
    fi
    rm markers.json

    # Finally delete the bucket
    echo "Deleting bucket..."
    aws s3 rb "s3://$BUCKET_NAME" --force --region "$REGION"

    echo "Cleanup complete. Bucket $BUCKET_NAME deleted."
else
    echo "Bucket $BUCKET_NAME does not exist. Skipping."
fi
