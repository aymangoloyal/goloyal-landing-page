# Conditional outputs based on cloud provider

# Azure outputs
output "azure_container_app_url" {
  description = "URL of the deployed Azure Container App"
  value       = "https://${azurerm_container_app.main[0].latest_revision_fqdn}"
}

output "azure_container_registry_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.main[0].login_server
  sensitive   = false
}

output "azure_resource_group_name" {
  description = "Azure resource group name"
  value       = azurerm_resource_group.main[0].name
}

output "azure_database_fqdn" {
  description = "Azure PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.main[0].fqdn
  sensitive   = false
}

# Common outputs
output "cloud_provider" {
  description = "The cloud provider used for deployment"
  value       = var.cloud_provider
}

output "environment" {
  description = "The deployment environment"
  value       = var.environment
}

output "app_name" {
  description = "The application name"
  value       = var.app_name
}

# Database URL (conditional)
output "database_url" {
  description = "Full database connection URL"
  value       = "postgresql://goloyal_admin:${var.db_admin_password != "" ? var.db_admin_password : random_password.azure_db_password[0].result}@${azurerm_postgresql_flexible_server.main[0].fqdn}:5432/${var.app_name}?sslmode=require"
  sensitive   = true
}
