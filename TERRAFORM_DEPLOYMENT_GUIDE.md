# Complete Terraform Deployment Guide for GoLoyal (Azure Only)

This comprehensive guide shows you how to deploy GoLoyal to **Azure** using Terraform. The GitHub Actions workflow handles Azure automatically, but this guide covers manual deployment for Azure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Azure Deployment](#azure-deployment)
4. [Configuration Options](#configuration-options)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

Install these tools on your local machine:

```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Verify installation
terraform --version
```

### Azure Tools
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version
```

### Docker (for container builds)
```bash
# Install Docker
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
```

## Project Structure

The Terraform configuration is organized as follows:

```
terraform/
├── providers.tf      # Provider configuration for Azure
├── variables.tf      # Input variables for Azure
├── azure.tf          # Azure-specific resources
├── outputs.tf        # Output values
└── terraform.tfvars.example  # Example configuration file
```

## Azure Deployment

### Step 1: Azure Setup

**1.1 Login to Azure**
```bash
az login
```

**1.2 Set your subscription**
```bash
# List available subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "Your Subscription Name"
```

**1.3 Create a service principal (optional for local development)**
```bash
# Create service principal for Terraform
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### Step 2: Configure Terraform for Azure

**2.1 Create terraform.tfvars file**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

**2.2 Edit terraform.tfvars for Azure**
```hcl
# Azure Configuration
app_name       = "goloyal"
environment    = "prod"

# Azure-specific settings
azure_location            = "East US"
azure_resource_group_name = ""  # Leave empty to auto-generate

# Database password (use a strong password)
db_admin_password = "YourSecurePassword123!"

# Optional: Container image (leave empty for default)
container_image = ""

# Scaling settings
min_instances = 0
max_instances = 10
cpu_limit     = "1000m"
memory_limit  = "1Gi"
```

### Step 3: Deploy to Azure

**3.1 Initialize Terraform**
```bash
terraform init
```

**3.2 Plan the deployment**
```bash
terraform plan
```

**3.3 Apply the infrastructure**
```bash
terraform apply
```

**3.4 Build and push your application container**
```bash
# Get the ACR login server from Terraform output
ACR_LOGIN_SERVER=$(terraform output -raw azure_container_registry_login_server)

# Login to Azure Container Registry
az acr login --name $(echo $ACR_LOGIN_SERVER | cut -d'.' -f1)

# Build and push your container
docker build -t $ACR_LOGIN_SERVER/goloyal-app:latest ..
docker push $ACR_LOGIN_SERVER/goloyal-app:latest

# Update the container app with your image
terraform apply -var="container_image=$ACR_LOGIN_SERVER/goloyal-app:latest"
```

**3.5 Get your application URL**
```bash
terraform output azure_container_app_url
```

### Step 4: Azure Post-Deployment

**4.1 Verify deployment**
```bash
# Check resource group
az group show --name $(terraform output -raw azure_resource_group_name)

# Check container app status
az containerapp show --name goloyal-prod-app --resource-group $(terraform output -raw azure_resource_group_name)
```

**4.2 View logs**
```bash
az containerapp logs show --name goloyal-prod-app --resource-group $(terraform output -raw azure_resource_group_name)
```

## Configuration Options

### Environment Variables

You can customize your deployment with these Terraform variables:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `app_name` | Application name | goloyal | No |
| `environment` | Environment (dev/staging/prod) | prod | No |
| `db_admin_password` | Database password | - | Yes |
| `azure_location` | Azure region | East US | No |
| `container_image` | Container image URL | auto-generated | No |
| `min_instances` | Minimum instances | 0 | No |
| `max_instances` | Maximum instances | 10 | No |
| `cpu_limit` | CPU limit | 1000m | No |
| `memory_limit` | Memory limit | 1Gi | No |

### Environment-Specific Deployments

**Development Environment:**
```hcl
environment   = "dev"
min_instances = 0
max_instances = 2
cpu_limit     = "500m"
memory_limit  = "512Mi"
```

**Staging Environment:**
```hcl
environment   = "staging"
min_instances = 1
max_instances = 5
cpu_limit     = "1000m"
memory_limit  = "1Gi"
```

**Production Environment:**
```hcl
environment   = "prod"
min_instances = 2
max_instances = 20
cpu_limit     = "2000m"
memory_limit  = "2Gi"
```

### Remote State Storage

For production deployments, configure remote state:

**Azure Backend:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestg"
    container_name       = "tfstate"
    key                  = "goloyal.terraform.tfstate"
  }
}
```

## Advanced Configuration

### Custom Domain Setup

**Azure Custom Domain:**
```bash
# Add custom domain to Container App
az containerapp hostname add \
    --resource-group $(terraform output -raw azure_resource_group_name) \
    --name goloyal-prod-app \
    --hostname yourdomain.com
```

### SSL Certificate Management

Azure Container Apps provide automatic SSL certificates for custom domains.

### Database Backup Configuration

**Azure PostgreSQL:**
```bash
# Configure backup retention
az postgres flexible-server parameter set \
    --resource-group $(terraform output -raw azure_resource_group_name) \
    --server-name $(terraform output -raw azure_database_fqdn | cut -d'.' -f1) \
    --name backup_retention_days \
    --value 30
```

## Troubleshooting

### Common Issues

**Issue: Terraform authentication fails**
```bash
az login
az account set --subscription "Your Subscription"
```

**Issue: Container registry authentication fails**
```bash
az acr login --name your-registry-name
```

**Issue: Database connection fails**
```bash
# Check network connectivity
# Azure: Verify VNet integration
```

**Issue: Insufficient permissions**
```bash
# Ensure Contributor role
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### Resource Cleanup

**Destroy all resources:**
```bash
terraform destroy
```

**Destroy specific resources:**
```bash
# Azure Container App only
terraform destroy -target=azurerm_container_app.main
```

### Monitoring and Logs

**Azure Monitoring:**
```bash
# View Container App metrics
az monitor metrics list \
    --resource $(terraform output -raw azure_container_app_url) \
    --metric "Requests"

# View logs
az monitor log-analytics query \
    --workspace $(terraform output -raw azure_resource_group_name) \
    --analytics-query "ContainerAppConsoleLogs_CL | limit 100"
```

## Cost Optimization

### Azure Cost Tips
- Use B-series VMs for development
- Enable auto-shutdown for dev environments
- Monitor resource usage with Azure Cost Management

## Security Best Practices

### Network Security
- Use private endpoints for databases
- Implement network security groups (Azure)
- Enable audit logging

### Access Control
- Use managed identities (Azure)
- Implement least privilege access
- Enable multi-factor authentication

### Data Protection
- Enable encryption at rest and in transit
- Configure automated backups
- Implement key rotation policies

## Next Steps

1. **Set up monitoring and alerting**
2. **Configure CI/CD pipelines**
3. **Implement blue-green deployments**
4. **Set up disaster recovery**
5. **Configure performance monitoring**

For additional support, refer to the official documentation:
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Terraform Documentation](https://terraform.io/docs)