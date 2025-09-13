#!/bin/bash

# Simple Azure Container Apps Deployment Script for GoLoyal Landing Page
# This script deploys the application to Azure Container Apps using Docker

set -e

# Configuration
APP_NAME="goloyal-landing-page"
RESOURCE_GROUP="goloyal-landing-rg"
LOCATION="East US"
CONTAINER_APP_NAME="goloyal-landing-app"
CONTAINER_APP_ENVIRONMENT="goloyal-env"
REGISTRY_NAME="goloyallandingregistry"
IMAGE_NAME="goloyal-landing-page"
IMAGE_TAG="latest"

echo "🚀 Starting deployment of $APP_NAME to Azure Container Apps..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

# Login to Azure (if not already logged in)
echo "🔐 Checking Azure authentication..."
if ! az account show &> /dev/null; then
    echo "Please log in to Azure..."
    az login
fi

# Set subscription (optional - uncomment and modify if needed)
# az account set --subscription "Your Subscription Name"

# Create resource group
echo "📦 Creating resource group: $RESOURCE_GROUP"
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

# Create Azure Container Registry
echo "🐳 Creating Azure Container Registry: $REGISTRY_NAME"
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $REGISTRY_NAME \
    --sku Basic \
    --admin-enabled true \
    --output table

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $REGISTRY_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
echo "📋 ACR Login Server: $ACR_LOGIN_SERVER"

# Login to ACR
echo "🔑 Logging in to Azure Container Registry..."
az acr login --name $REGISTRY_NAME

# Build and push Docker image
echo "🔨 Building Docker image..."
docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG ..

echo "📤 Pushing image to Azure Container Registry..."
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG

# Create Container Apps environment
echo "🌍 Creating Container Apps environment: $CONTAINER_APP_ENVIRONMENT"
az containerapp env create \
    --name $CONTAINER_APP_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

# Create Container App
echo "🚀 Creating Container App: $CONTAINER_APP_NAME"
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $CONTAINER_APP_ENVIRONMENT \
    --image $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG \
    --target-port 5000 \
    --ingress external \
    --registry-server $ACR_LOGIN_SERVER \
    --query properties.configuration.ingress.fqdn \
    --output tsv

# Get the application URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    --output tsv)

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Your application is available at: https://$APP_URL"
echo ""
echo "📋 Deployment Summary:"
echo "   - App Name: $APP_NAME"
echo "   - Resource Group: $RESOURCE_GROUP"
echo "   - Container App: $CONTAINER_APP_NAME"
echo "   - Registry: $REGISTRY_NAME"
echo "   - URL: https://$APP_URL"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Update app: az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --image $ACR_LOGIN_SERVER/$IMAGE_NAME:new-tag"
echo "   Delete resources: az group delete --name $RESOURCE_GROUP --yes"
