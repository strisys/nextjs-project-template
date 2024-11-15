#!/bin/bash

# Set AWS environment variables
export AWS_CONFIG_FILE="/home/vscode/.aws/config"
export AWS_DEFAULT_SSO_START_URL="https://d-9067e9d2c0.awsapps.com/start/#"
export AWS_DEFAULT_SSO_REGION="us-east-1"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_DEFAULT_OUTPUT="json"

# Set the AWS profile name
export AWS_PROFILE_NAME="default"

# Create AWS config file if it doesn't exist
mkdir -p ~/.aws
touch ~/.aws/config

# Configure AWS SSO
aws configure set sso_start_url $AWS_DEFAULT_SSO_START_URL --profile $AWS_PROFILE_NAME
aws configure set sso_region $AWS_DEFAULT_SSO_REGION --profile $AWS_PROFILE_NAME
aws configure set region $AWS_DEFAULT_REGION --profile $AWS_PROFILE_NAME
aws configure set output $AWS_DEFAULT_OUTPUT --profile $AWS_PROFILE_NAME
echo "AWS SSO configuration completed for profile: $AWS_PROFILE_NAME"

# Function to check if SSO session is valid
check_sso_session() {
    if aws sts get-caller-identity --profile $AWS_PROFILE_NAME &>/dev/null; then
        return 0  # Session is valid
    else
        return 1  # Session is invalid or expired
    fi
}

# Check if SSO session is valid, if not, attempt login
if check_sso_session; then
    echo "AWS SSO session is already valid for profile: $AWS_PROFILE_NAME. No need to login."
else
    echo "AWS SSO session is invalid or expired for profile: $AWS_PROFILE_NAME. Attempting SSO login..."
    aws sso login --profile $AWS_PROFILE_NAME
fi