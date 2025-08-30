# Azure Resources for GoLoyal Application

locals {
  azure_resource_group_name = var.azure_resource_group_name != "" ? var.azure_resource_group_name : "${var.app_name}-${var.environment}-rg"
  azure_resource_prefix     = "${var.app_name}-${var.environment}"
  azure_tags = {
    application = var.app_name
    environment = var.environment
    managedBy   = "terraform"
    version     = "1.0.0"
  }


}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.azure_resource_group_name
  location = var.azure_location
  tags     = local.azure_tags
}

# Log Analytics Workspace for Container Apps
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.azure_resource_prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.azure_tags
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${local.azure_resource_prefix}-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.azure_tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = replace("${local.azure_resource_prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.azure_tags
}

# Virtual Network for PostgreSQL (only if private network is enabled)
resource "azurerm_virtual_network" "main" {
  count               = var.enable_private_network ? 1 : 0
  name                = "${local.azure_resource_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.azure_tags
}

# Subnet for PostgreSQL (only if private network is enabled)
resource "azurerm_subnet" "database" {
  count                = var.enable_private_network ? 1 : 0
  name                 = "database-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "PostgreSQLDelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
}

# Private DNS Zone for PostgreSQL (only if private network is enabled)
resource "azurerm_private_dns_zone" "postgres" {
  count               = var.enable_private_network ? 1 : 0
  name                = "${local.azure_resource_prefix}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.azure_tags
}

# Link DNS Zone to VNet (only if private network is enabled)
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count                 = var.enable_private_network ? 1 : 0
  name                  = "${local.azure_resource_prefix}-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.main[0].id
  resource_group_name   = azurerm_resource_group.main.name
  tags                  = local.azure_tags
}

# Generate random password if not provided
resource "random_password" "azure_db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "${local.azure_resource_prefix}-postgres"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  version                       = "15"
  delegated_subnet_id           = var.enable_private_network ? azurerm_subnet.database[0].id : null
  private_dns_zone_id           = var.enable_private_network ? azurerm_private_dns_zone.postgres[0].id : null
  public_network_access_enabled = !var.enable_private_network
  administrator_login           = "goloyal_admin"
  administrator_password        = var.db_admin_password != "" ? var.db_admin_password : random_password.azure_db_password.result
  zone                          = "1"
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = false

  tags = local.azure_tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.app_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Container App
resource "azurerm_container_app" "main" {
  name                         = "${local.azure_resource_prefix}-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.azure_tags

  template {
    container {
      name   = "${var.app_name}-app"
      image  = var.container_image != "" ? var.container_image : "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = tonumber(replace(var.cpu_limit, "m", "")) / 1000
      memory = var.memory_limit

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "PORT"
        value = "5000"
      }

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }

      env {
        name  = "APP_NAME"
        value = var.app_name
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    }

    min_replicas = var.min_instances
    max_replicas = var.max_instances
  }

  secret {
    name  = "database-url"
    value = "postgresql://goloyal_admin:${var.db_admin_password != "" ? var.db_admin_password : random_password.azure_db_password.result}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.app_name}?sslmode=require"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.main.admin_password
  }

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "registry-password"
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 5000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# Application Insights for monitoring
resource "azurerm_application_insights" "main" {
  name                = "${local.azure_resource_prefix}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.azure_tags
}

# Key Vault for secrets management (optional)
resource "azurerm_key_vault" "main" {
  count                       = var.environment == "prod" ? 1 : 0
  name                        = "${local.azure_resource_prefix}-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = local.azure_tags
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}
