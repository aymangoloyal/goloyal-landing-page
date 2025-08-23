#!/bin/bash

# GoLoyal Azure Setup Script
# This script sets up the necessary Azure resources and permissions for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="goloyal"
ENVIRONMENT="${1:-prod}"
LOCATION="${2:-eastus}"
RESOURCE_GROUP_NAME="${APP_NAME}-${ENVIRONMENT}-${LOCATION}-rg"

echo -e "${BLUE}🚀 Setting up Azure resources for GoLoyal${NC}"
echo -e "${BLUE}Application: ${APP_NAME}${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Location: ${LOCATION}${NC}"
echo -e "${BLUE}Resource Group: ${RESOURCE_GROUP_NAME}${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  You are not logged in to Azure. Please log in first.${NC}"
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}✅ Using subscription: ${SUBSCRIPTION_ID}${NC}"

# Create resource group
echo -e "${BLUE}📦 Creating resource group...${NC}"
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION

# Create service principal for GitHub Actions
echo -e "${BLUE}🔑 Creating service principal for GitHub Actions...${NC}"
SP_NAME="${APP_NAME}-${ENVIRONMENT}-github-sp"

# Create service principal and assign contributor role
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name $SP_NAME \
    --role Contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME \
    --sdk-auth)

echo -e "${GREEN}✅ Service principal created successfully!${NC}"

# Generate a secure password for database
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

echo -e "${BLUE}📋 GitHub Secrets Configuration${NC}"
echo -e "${YELLOW}Please add the following secrets to your GitHub repository:${NC}"
echo ""
echo -e "${GREEN}AZURE_CREDENTIALS:${NC}"
echo "$SP_OUTPUT"
echo ""
echo -e "${GREEN}AZURE_DB_PASSWORD:${NC}"
echo "$DB_PASSWORD"
echo ""

# Create GitHub Variables
echo -e "${BLUE}📋 GitHub Variables Configuration${NC}"
echo -e "${YELLOW}Please add the following variables to your GitHub repository:${NC}"
echo ""
echo -e "${GREEN}AZURE_LOCATION:${NC}"
echo "$LOCATION"
echo ""

# Deploy initial infrastructure
echo -e "${BLUE}🏗️  Deploying initial infrastructure...${NC}"
az deployment group create \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file azure/main.bicep \
    --parameters \
        appName=$APP_NAME \
        environment=$ENVIRONMENT \
        dbAdminPassword=$DB_PASSWORD \
        location=$LOCATION

echo -e "${GREEN}🎉 Azure setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1. Add the GitHub secrets shown above to your repository${NC}"
echo -e "${YELLOW}2. Add the GitHub variables shown above to your repository${NC}"
echo -e "${YELLOW}3. Push your code to trigger the deployment pipeline${NC}"
echo ""
echo -e "${BLUE}Resource Group: ${RESOURCE_GROUP_NAME}${NC}"
echo -e "${BLUE}Location: ${LOCATION}${NC}"