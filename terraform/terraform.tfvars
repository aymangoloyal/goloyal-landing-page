# Multi-Cloud Terraform Configuration Example
# Copy this file to terraform.tfvars and fill in your values

# Required: Choose cloud provider
cloud_provider = "azure" # or "gcp"

# Required: Application settings
app_name    = "goloyal"
environment = "prod"

# Required: Database password
db_admin_password = "your-secure-password-here"

# Azure-specific settings (only needed if cloud_provider = "azure")
azure_location            = "UK South"
azure_resource_group_name = "" # Leave empty to auto-generate

# Optional: Container image (leave empty for default)
container_image = ""

# Optional: Scaling settings
min_instances = 0
max_instances = 10
cpu_limit     = "1000m"
memory_limit  = "2Gi"
