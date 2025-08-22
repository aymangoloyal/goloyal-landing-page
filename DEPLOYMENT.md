# GoLoyal Deployment Guide

This guide will help you deploy your GoLoyal application to Google Cloud Platform using GitHub Actions and Terraform.

## Prerequisites

1. **Google Cloud Platform Account**
   - Create a GCP project
   - Enable billing for the project

2. **GitHub Repository**
   - Push your code to a GitHub repository
   - You'll need admin access to configure secrets

## Setup Instructions

### 1. GCP Setup

1. **Create a Service Account:**
   ```bash
   # Set your project ID
   export PROJECT_ID="your-project-id"
   
   # Create service account
   gcloud iam service-accounts create goloyal-deployer \
     --description="Service account for GoLoyal deployment" \
     --display-name="GoLoyal Deployer"
   
   # Add required roles
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/run.admin"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/sql.admin"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/compute.networkAdmin"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   
   # Create and download service account key
   gcloud iam service-accounts keys create key.json \
     --iam-account=goloyal-deployer@$PROJECT_ID.iam.gserviceaccount.com
   ```

2. **Enable Required APIs:**
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable sql-component.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable compute.googleapis.com
   gcloud services enable servicenetworking.googleapis.com
   ```

### 2. GitHub Secrets Setup

In your GitHub repository, go to Settings > Secrets and variables > Actions, and add:

- **GCP_PROJECT_ID**: Your GCP project ID
- **GCP_SA_KEY**: The entire content of the `key.json` file you downloaded
- **DATABASE_URL**: This will be set automatically after first deployment, but you can set a placeholder initially

### 3. Terraform Configuration

1. **Copy the example configuration:**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. **Edit `terraform/terraform.tfvars`:**
   ```hcl
   project_id = "your-actual-project-id"
   region     = "us-central1"  # or your preferred region
   ```

### 4. Deploy

1. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Add deployment configuration"
   git push origin main
   ```

2. **Monitor the deployment:**
   - Go to your GitHub repository
   - Click on the "Actions" tab
   - Watch the deployment workflow run

### 5. Post-Deployment

After successful deployment:

1. **Get your application URL:**
   ```bash
   gcloud run services describe goloyal-app \
     --platform managed \
     --region us-central1 \
     --format 'value(status.url)'
   ```

2. **Set up custom domain (optional):**
   - Uncomment the domain mapping in `terraform/main.tf`
   - Update the `domain_name` variable
   - Run terraform apply again

## Architecture Overview

Your deployed application will include:

- **Cloud Run**: Serverless container hosting your application
- **Cloud SQL**: PostgreSQL database for data persistence
- **VPC Network**: Private network for secure communication
- **Container Registry**: Stores your Docker images
- **Load Balancer**: Automatically managed by Cloud Run

## Monitoring and Maintenance

- **Logs**: View in GCP Console > Cloud Run > your-service > Logs
- **Metrics**: Available in GCP Console > Cloud Run > your-service > Metrics
- **Database**: Accessible via GCP Console > SQL

## Cost Optimization

- Cloud Run automatically scales to zero when not in use
- Database uses the smallest instance size (`db-f1-micro`)
- You only pay for actual usage

## Troubleshooting

1. **Build fails**: Check the GitHub Actions logs for specific error messages
2. **Database connection issues**: Ensure the VPC connector is properly configured
3. **Permission errors**: Verify all required IAM roles are assigned to the service account

## Security Considerations

- Database is in a private network (not accessible from internet)
- All traffic is encrypted in transit
- Service account follows principle of least privilege
- Container runs as non-root user

For additional help, check the GitHub Actions workflow logs and Terraform output for specific error messages.