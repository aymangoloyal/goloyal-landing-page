# GoLoyal Landing Page - Azure Deployment

This directory contains a simple deployment script to deploy the GoLoyal Landing Page to Azure Container Apps using Docker.

## Prerequisites

Before deploying, make sure you have the following installed:

1. **Azure CLI** - Install from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Docker** - Install from [here](https://docs.docker.com/get-docker/)
3. **Azure Account** - You need an active Azure subscription

## Quick Deployment

1. **Login to Azure:**
   ```bash
   az login
   ```

2. **Run the deployment script:**
   ```bash
   ./deploy.sh
   ```

That's it! The script will:
- Create a resource group
- Set up Azure Container Registry
- Build and push your Docker image
- Deploy to Azure Container Apps
- Provide you with the application URL

## What Gets Created

The deployment script creates the following Azure resources:

- **Resource Group**: `goloyal-landing-rg`
- **Container Registry**: `goloyallandingregistry`
- **Container Apps Environment**: `goloyal-env`
- **Container App**: `goloyal-landing-app`

## Configuration

You can modify the deployment by editing the variables at the top of `deploy.sh`:

```bash
APP_NAME="goloyal-landing-page"
RESOURCE_GROUP="goloyal-landing-rg"
LOCATION="East US"
CONTAINER_APP_NAME="goloyal-landing-app"
CONTAINER_APP_ENVIRONMENT="goloyal-env"
REGISTRY_NAME="goloyallandingregistry"
IMAGE_NAME="goloyal-landing-page"
IMAGE_TAG="latest"
```

## Useful Commands

After deployment, you can use these Azure CLI commands:

**View application logs:**
```bash
az containerapp logs show --name goloyal-landing-app --resource-group goloyal-landing-rg
```

**Update the application:**
```bash
# Build and push new image
docker build -t goloyallandingregistry.azurecr.io/goloyal-landing-page:new-tag .
docker push goloyallandingregistry.azurecr.io/goloyal-landing-page:new-tag

# Update the container app
az containerapp update --name goloyal-landing-app --resource-group goloyal-landing-rg --image goloyallandingregistry.azurecr.io/goloyal-landing-page:new-tag
```

**Scale the application:**
```bash
az containerapp update --name goloyal-landing-app --resource-group goloyal-landing-rg --min-replicas 2 --max-replicas 10
```

**Delete all resources:**
```bash
az group delete --name goloyal-landing-rg --yes
```

## Troubleshooting

**If the deployment fails:**
1. Make sure you're logged into Azure: `az login`
2. Check your Azure subscription: `az account show`
3. Ensure you have sufficient permissions in your Azure subscription

**If the Docker build fails:**
1. Make sure Docker is running: `docker --version`
2. Check the Dockerfile exists in the project root
3. Ensure all dependencies are properly configured

**If the container app doesn't start:**
1. Check the logs: `az containerapp logs show --name goloyal-landing-app --resource-group goloyal-landing-rg`
2. Verify the image was pushed successfully to the registry
3. Check the container app configuration

## Cost Optimization

- The deployment uses Azure Container Apps which charges based on usage
- The Basic tier Container Registry is used for cost efficiency
- You can stop the container app when not in use to minimize costs

## Security Notes

- The deployment script creates resources with default security settings
- For production use, consider:
  - Using managed identities instead of admin-enabled registries
  - Implementing network security groups
  - Setting up proper RBAC permissions
  - Using Azure Key Vault for secrets management
