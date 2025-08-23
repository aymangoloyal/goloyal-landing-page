# Multi-Cloud Deployment Guide for GoLoyal

This comprehensive guide covers deploying the GoLoyal application to both **Microsoft Azure** and **Google Cloud Platform (GCP)** using GitHub Actions CI/CD pipelines.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Comparison](#architecture-comparison)
3. [Prerequisites](#prerequisites)
4. [Azure Deployment](#azure-deployment)
5. [GCP Deployment](#gcp-deployment)
6. [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
7. [Deployment Strategies](#deployment-strategies)
8. [Monitoring and Management](#monitoring-and-management)
9. [Cost Optimization](#cost-optimization)
10. [Troubleshooting](#troubleshooting)

## Overview

The GoLoyal application can be deployed to either Azure or GCP (or both) using a single GitHub Actions workflow. The deployment uses:

- **Containerization**: Docker containers for consistent deployment
- **Infrastructure as Code**: Bicep for Azure, Terraform for GCP
- **Serverless Computing**: Azure Container Apps and GCP Cloud Run
- **Managed Databases**: Azure Database for PostgreSQL and GCP Cloud SQL
- **Automated CI/CD**: GitHub Actions with multi-cloud support

## Architecture Comparison

| Component | Azure | GCP |
|-----------|-------|-----|
| **Application Hosting** | Azure Container Apps | Cloud Run |
| **Database** | Azure Database for PostgreSQL | Cloud SQL (PostgreSQL) |
| **Container Registry** | Azure Container Registry | Google Container Registry |
| **Networking** | Azure Virtual Network | VPC Network |
| **Infrastructure as Code** | Bicep Templates | Terraform |
| **Monitoring** | Azure Monitor | Cloud Monitoring |
| **DNS & SSL** | Automatic via Container Apps | Automatic via Cloud Run |

### Recommended Choice: **Azure Container Apps**

**Why Azure is recommended for GoLoyal:**

1. **Cost-effectiveness**: Better pricing for small to medium applications
2. **Simplified networking**: Built-in load balancing and SSL
3. **Integrated monitoring**: Comprehensive logging and metrics
4. **Developer experience**: More intuitive management interface
5. **Startup credits**: Better free tier and startup programs

## Prerequisites

### Required Tools
- **Azure CLI** (for Azure deployment)
- **Google Cloud SDK** (for GCP deployment)
- **GitHub account** with repository access
- **Docker** (for local testing)

### Required Accounts
- **Azure subscription** with billing enabled
- **GCP project** with billing enabled
- **GitHub repository** with admin access

## Azure Deployment

### 1. Azure Setup

Run the setup script to configure Azure resources:

```bash
# Make the script executable
chmod +x scripts/setup-azure.sh

# Run setup (replace 'prod' and 'eastus' with your preferences)
./scripts/setup-azure.sh prod eastus
```

**What this script does:**
- Creates a resource group
- Sets up service principal for GitHub Actions
- Generates secure database password
- Deploys initial infrastructure using Bicep

### 2. Azure Infrastructure (Bicep)

The `azure/main.bicep` template creates:

- **Resource Group**: Container for all resources
- **Container Apps Environment**: Serverless container platform
- **Azure Container Registry**: Private container storage
- **PostgreSQL Flexible Server**: Managed database with private networking
- **Virtual Network**: Secure networking for database access
- **Log Analytics Workspace**: Centralized logging

### 3. Azure GitHub Secrets

Add these secrets to your GitHub repository:

```yaml
# Settings > Secrets and variables > Actions
AZURE_CREDENTIALS: # Service principal JSON from setup script
AZURE_DB_PASSWORD: # Database password from setup script
```

Add these variables:

```yaml
# Settings > Secrets and variables > Actions > Variables
AZURE_LOCATION: eastus  # Your preferred Azure region
```

### 4. Azure Deployment Features

- **Auto-scaling**: 0-10 instances based on demand
- **Health checks**: Automatic container health monitoring
- **SSL certificates**: Automatic HTTPS with custom domains
- **Private database**: Secure PostgreSQL with VNet integration
- **Monitoring**: Built-in metrics and log aggregation

## GCP Deployment

### 1. GCP Setup

Run the setup script to configure GCP resources:

```bash
# Make the script executable
chmod +x scripts/setup-gcp.sh

# Run setup (replace with your project ID and preferred region)
./scripts/setup-gcp.sh your-project-id us-central1
```

**What this script does:**
- Enables required Google Cloud APIs
- Creates service account with necessary permissions
- Generates service account key for GitHub Actions
- Provides Terraform configuration instructions

### 2. GCP Infrastructure (Terraform)

The `terraform/main.tf` creates:

- **Cloud Run Service**: Serverless container platform
- **Cloud SQL Instance**: Managed PostgreSQL database
- **VPC Network**: Private networking for secure communication
- **VPC Access Connector**: Connects Cloud Run to private resources
- **IAM Roles**: Secure service account permissions

### 3. GCP GitHub Secrets

Add these secrets to your GitHub repository:

```yaml
# Settings > Secrets and variables > Actions
GCP_PROJECT_ID: your-project-id
GCP_SA_KEY: # Service account JSON from setup script
GCP_DATABASE_URL: # Generated automatically by Terraform
```

Add these variables:

```yaml
# Settings > Secrets and variables > Actions > Variables
GCP_REGION: us-central1  # Your preferred GCP region
```

### 4. GCP Deployment Features

- **Global load balancing**: Automatic traffic distribution
- **Cold start optimization**: Fast container startup
- **VPC security**: Database isolated in private network
- **Terraform state**: Infrastructure versioning and rollback
- **Cloud Build integration**: Optimized container builds

## CI/CD Pipeline Configuration

### Multi-Cloud Workflow

The `.github/workflows/deploy-multicloud.yml` provides:

1. **Automated Testing**: Runs tests and builds on every push
2. **Environment Selection**: Deploy to dev, staging, or prod
3. **Cloud Provider Choice**: Deploy to Azure, GCP, or both
4. **Manual Triggers**: Workflow dispatch for manual deployments
5. **Deployment Summary**: Detailed results in GitHub UI

### Workflow Triggers

```yaml
# Automatic on main branch push
on:
  push:
    branches: [ main ]

# Manual deployment with options
workflow_dispatch:
  inputs:
    target_cloud:
      description: 'Target cloud provider'
      type: choice
      options: [azure, gcp, both]
    environment:
      description: 'Deployment environment'  
      type: choice
      options: [dev, staging, prod]
```

### Deployment Jobs

1. **Test Job**: Runs tests and builds application
2. **Deploy Azure Job**: Deploys to Azure Container Apps
3. **Deploy GCP Job**: Deploys to Google Cloud Run
4. **Summary Job**: Aggregates deployment results

## Deployment Strategies

### 1. Single Cloud Deployment

**Deploy only to Azure:**
```bash
# Use GitHub UI workflow dispatch
Target Cloud: azure
Environment: prod
```

**Deploy only to GCP:**
```bash
# Use GitHub UI workflow dispatch  
Target Cloud: gcp
Environment: prod
```

### 2. Multi-Cloud Deployment

**Deploy to both clouds:**
```bash
# Use GitHub UI workflow dispatch
Target Cloud: both
Environment: prod
```

### 3. Environment-Specific Deployment

**Development Environment:**
- Smaller resource allocations
- Simplified networking
- Reduced monitoring

**Production Environment:**
- Auto-scaling enabled
- Enhanced security
- Full monitoring suite
- Backup strategies

### 4. Blue-Green Deployment

Both platforms support blue-green deployments:

**Azure Container Apps:**
- Traffic splitting between revisions
- Gradual rollout capabilities
- Instant rollback options

**GCP Cloud Run:**
- Revision-based deployments
- Traffic allocation controls
- Zero-downtime deployments

## Monitoring and Management

### Azure Monitoring

**Azure Monitor Integration:**
- Application Insights for performance
- Log Analytics for centralized logs
- Metrics for resource utilization
- Alerts for critical events

**Key Metrics:**
- Request count and response times
- Container CPU and memory usage
- Database connection health
- Error rates and exceptions

### GCP Monitoring

**Google Cloud Operations:**
- Cloud Monitoring for metrics
- Cloud Logging for log aggregation
- Error Reporting for exception tracking
- Cloud Trace for request tracing

**Key Metrics:**
- Cloud Run request metrics
- Database performance metrics
- Network latency and throughput
- Container resource utilization

### Alerting Setup

**Recommended Alerts:**
- High error rates (>5%)
- Response time degradation (>2s)
- Database connection failures
- Memory or CPU threshold breaches

## Cost Optimization

### Azure Cost Optimization

1. **Container Apps Scaling:**
   - Minimum instances: 0 (scale to zero)
   - Maximum instances: 10 (adjust based on traffic)
   - CPU/Memory: Right-size based on usage

2. **Database Optimization:**
   - Use Burstable tier for variable workloads
   - Enable auto-scaling for storage
   - Schedule maintenance during low-traffic periods

3. **Networking:**
   - Use private endpoints to reduce data transfer costs
   - Implement CDN for static assets

### GCP Cost Optimization

1. **Cloud Run Optimization:**
   - Request-based pricing (no idle costs)
   - Concurrent request limit tuning
   - CPU allocation optimization

2. **Cloud SQL Optimization:**
   - Use smallest instance size that meets performance needs
   - Enable automatic storage increases
   - Implement connection pooling

3. **Data Transfer:**
   - Use same region for all resources
   - Implement caching strategies

### Cost Comparison

| Resource Type | Azure | GCP | Winner |
|---------------|-------|-----|---------|
| **Compute** | $0.000024/vCPU-second | $0.000024/vCPU-second | Tie |
| **Database** | $0.0225/hour (B1ms) | $0.0250/hour (db-f1-micro) | Azure |
| **Storage** | $0.045/GB/month | $0.040/GB/month | GCP |
| **Networking** | $0.087/GB egress | $0.085/GB egress | GCP |

**Overall Winner: Azure** (for typical SaaS applications)

## Troubleshooting

### Common Azure Issues

**Issue: Container App deployment fails**
```bash
# Check deployment status
az containerapp show --name goloyal-prod-app --resource-group goloyal-prod-rg

# View logs
az containerapp logs show --name goloyal-prod-app --resource-group goloyal-prod-rg
```

**Issue: Database connection fails**
```bash
# Verify network configuration
az postgres flexible-server show --name goloyal-prod-postgres --resource-group goloyal-prod-rg

# Check firewall rules
az postgres flexible-server firewall-rule list --name goloyal-prod-postgres --resource-group goloyal-prod-rg
```

### Common GCP Issues

**Issue: Cloud Run deployment fails**
```bash
# Check service status
gcloud run services describe goloyal-app --region=us-central1

# View logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=goloyal-app"
```

**Issue: Database connection fails**
```bash
# Check Cloud SQL instance
gcloud sql instances describe goloyal-postgres-instance

# Verify VPC connector
gcloud compute networks vpc-access connectors describe goloyal-connector --region=us-central1
```

### GitHub Actions Issues

**Issue: Workflow fails to authenticate**
- Verify GitHub secrets are correctly set
- Check service account permissions
- Ensure subscription/project billing is enabled

**Issue: Docker build fails**
- Check Dockerfile syntax
- Verify all dependencies are available
- Review build logs in GitHub Actions

### Performance Issues

**High Response Times:**
1. Check container resource allocation
2. Verify database query performance
3. Monitor network latency
4. Consider implementing caching

**Database Connection Pool Exhaustion:**
1. Optimize connection management in application
2. Implement connection pooling
3. Scale database instance if needed

## Security Best Practices

### Azure Security

1. **Container Security:**
   - Use managed identity for service authentication
   - Implement least privilege access
   - Enable container image scanning

2. **Database Security:**
   - Use private endpoints for database access
   - Enable SSL/TLS encryption
   - Implement backup encryption

3. **Network Security:**
   - Use virtual networks for isolation
   - Implement network security groups
   - Enable DDoS protection

### GCP Security

1. **Cloud Run Security:**
   - Use service accounts with minimal permissions
   - Enable Binary Authorization
   - Implement VPC security controls

2. **Cloud SQL Security:**
   - Use private IP for database connections
   - Enable automatic backups
   - Implement SSL certificate validation

3. **Network Security:**
   - Use VPC firewall rules
   - Implement Cloud Armor for DDoS protection
   - Enable audit logging

## Conclusion

Both Azure and GCP provide excellent platforms for deploying the GoLoyal application. The choice depends on your specific requirements:

**Choose Azure if:**
- Cost optimization is a priority
- You prefer simpler management interfaces
- You're already using Microsoft ecosystem tools
- You need excellent startup support programs

**Choose GCP if:**
- You need global scale and performance
- You prefer Google's AI/ML integration capabilities
- You require advanced networking features
- You're already using Google Workspace

**Multi-cloud approach if:**
- You need high availability across providers
- You want to avoid vendor lock-in
- You have compliance requirements for geographic distribution
- You want to optimize costs by choosing best services from each provider

The GitHub Actions workflow provided supports all these scenarios, making it easy to deploy to either platform or both simultaneously.