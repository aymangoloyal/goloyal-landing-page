#!/bin/bash

# GoLoyal GCP Setup Script
# This script sets up the necessary GCP resources and permissions for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="${1}"
REGION="${2:-us-central1}"
SERVICE_ACCOUNT_NAME="goloyal-deployer"

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ Usage: $0 <PROJECT_ID> [REGION]${NC}"
    echo -e "${YELLOW}Example: $0 my-project-id us-central1${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Setting up GCP resources for GoLoyal${NC}"
echo -e "${BLUE}Project ID: ${PROJECT_ID}${NC}"
echo -e "${BLUE}Region: ${REGION}${NC}"

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}Install from: https://cloud.google.com/sdk/docs/install${NC}"
    exit 1
fi

# Set the project
echo -e "${BLUE}🔧 Setting GCP project...${NC}"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${BLUE}🔌 Enabling required APIs...${NC}"
gcloud services enable \
    run.googleapis.com \
    sql-component.googleapis.com \
    sqladmin.googleapis.com \
    compute.googleapis.com \
    servicenetworking.googleapis.com \
    cloudbuild.googleapis.com

# Create service account
echo -e "${BLUE}👤 Creating service account...${NC}"
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Service account for GoLoyal deployment" \
    --display-name="GoLoyal Deployer" || true

# Add IAM roles
echo -e "${BLUE}🔑 Adding IAM roles...${NC}"
ROLES=(
    "roles/run.admin"
    "roles/sql.admin"
    "roles/compute.networkAdmin"
    "roles/iam.serviceAccountUser"
    "roles/storage.admin"
    "roles/cloudbuild.builds.editor"
)

for role in "${ROLES[@]}"; do
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
        --role="$role"
done

# Create and download service account key
echo -e "${BLUE}🔐 Creating service account key...${NC}"
gcloud iam service-accounts keys create key.json \
    --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# Read the key file content
KEY_CONTENT=$(cat key.json | tr -d '\n')

echo -e "${GREEN}✅ GCP setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 GitHub Secrets Configuration${NC}"
echo -e "${YELLOW}Please add the following secrets to your GitHub repository:${NC}"
echo ""
echo -e "${GREEN}GCP_PROJECT_ID:${NC}"
echo "$PROJECT_ID"
echo ""
echo -e "${GREEN}GCP_SA_KEY:${NC}"
echo "$KEY_CONTENT"
echo ""

# Create GitHub Variables
echo -e "${BLUE}📋 GitHub Variables Configuration${NC}"
echo -e "${YELLOW}Please add the following variables to your GitHub repository:${NC}"
echo ""
echo -e "${GREEN}GCP_REGION:${NC}"
echo "$REGION"
echo ""

# Clean up the key file
rm key.json

echo -e "${BLUE}🏗️  Initialize Terraform (optional):${NC}"
echo -e "${YELLOW}Run the following commands to set up Terraform:${NC}"
echo ""
echo "cd terraform"
echo "terraform init"
echo "cp terraform.tfvars.example terraform.tfvars"
echo "# Edit terraform.tfvars with your project details"
echo ""

echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1. Add the GitHub secrets shown above to your repository${NC}"
echo -e "${YELLOW}2. Add the GitHub variables shown above to your repository${NC}"
echo -e "${YELLOW}3. Configure Terraform variables if using infrastructure as code${NC}"
echo -e "${YELLOW}4. Push your code to trigger the deployment pipeline${NC}"