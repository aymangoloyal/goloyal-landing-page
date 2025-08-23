#!/bin/bash

# GoLoyal Azure Cleanup Script
# This script deletes the Azure resources and service principal created by setup-azure.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME="goloyalio"
ENVIRONMENT="${1:-prod}"
LOCATION="${2:-eastus}"
RESOURCE_GROUP_NAME="${APP_NAME}-${ENVIRONMENT}-${LOCATION}-rg"
SP_NAME="${APP_NAME}-${ENVIRONMENT}-github-sp"

echo -e "${BLUE}🧹 Cleaning up Azure resources for GoLoyal${NC}"
echo -e "${BLUE}Resource Group: ${RESOURCE_GROUP_NAME}${NC}"
echo -e "${BLUE}Service Principal: ${SP_NAME}${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  You are not logged in to Azure. Please log in first.${NC}"
    az login
fi

# Delete resource group
echo -e "${BLUE}🗑️  Deleting resource group...${NC}"
az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

# Delete service principal
echo -e "${BLUE}🗑️  Deleting service principal...${NC}"
SP_APP_ID=$(az ad sp list --display-name $SP_NAME --query "[0].appId" -o tsv)
if [ -n "$SP_APP_ID" ]; then
    az ad sp delete --id $SP_APP_ID
    echo -e "${GREEN}✅ Service principal deleted.${NC}"
else
    echo -e "${YELLOW}⚠️  Service principal not found. Skipping.${NC}"
fi

echo -e "${GREEN}🎉 Azure cleanup completed!${NC}"