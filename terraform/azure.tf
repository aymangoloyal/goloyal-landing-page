# Azure Resources - Only created when cloud_provider = "azure"

locals {
  azure_resource_group_name = var.azure_resource_group_name != "" ? var.azure_resource_group_name : "${var.app_name}-${var.environment}-rg"
  azure_resource_prefix     = "${var.app_name}-${var.environment}"
  azure_tags = {
    application = var.app_name
    environment = var.environment
    managedBy   = "terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  name     = local.azure_resource_group_name
  location = var.azure_location
  tags     = local.azure_tags
}

# Log Analytics Workspace for Container Apps
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${local.azure_resource_prefix}-logs"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.azure_tags
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  count                      = var.cloud_provider == "azure" ? 1 : 0
  name                       = "${local.azure_resource_prefix}-env"
  location                   = azurerm_resource_group.main[0].location
  resource_group_name        = azurerm_resource_group.main[0].name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
  tags                       = local.azure_tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = replace("${local.azure_resource_prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.azure_tags
}

# Virtual Network for PostgreSQL
resource "azurerm_virtual_network" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${local.azure_resource_prefix}-vnet"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  address_space       = ["10.0.0.0/16"]
  tags                = local.azure_tags
}

# Subnet for PostgreSQL
resource "azurerm_subnet" "database" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  name                 = "database-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "PostgreSQLDelegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${local.azure_resource_prefix}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main[0].name
  tags                = local.azure_tags
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count                 = var.cloud_provider == "azure" ? 1 : 0
  name                  = "${local.azure_resource_prefix}-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.main[0].id
  resource_group_name   = azurerm_resource_group.main[0].name
  tags                  = local.azure_tags
}

# Generate random password if not provided
resource "random_password" "azure_db_password" {
  count   = var.cloud_provider == "azure" ? 1 : 0
  length  = 16
  special = true
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  count                         = var.cloud_provider == "azure" ? 1 : 0
  name                          = "${local.azure_resource_prefix}-postgres"
  resource_group_name           = azurerm_resource_group.main[0].name
  location                      = azurerm_resource_group.main[0].location
  version                       = "15"
  delegated_subnet_id           = azurerm_subnet.database[0].id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres[0].id
  public_network_access_enabled = false # 🚀 Fix: disable public access
  administrator_login           = "goloyal_admin"
  administrator_password        = var.db_admin_password != "" ? var.db_admin_password : random_password.azure_db_password[0].result
  zone                          = "1"
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false

  tags = local.azure_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}


# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  count     = var.cloud_provider == "azure" ? 1 : 0
  name      = var.app_name
  server_id = azurerm_postgresql_flexible_server.main[0].id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Container App
resource "azurerm_container_app" "main" {
  count                        = var.cloud_provider == "azure" ? 1 : 0
  name                         = "${local.azure_resource_prefix}-app"
  container_app_environment_id = azurerm_container_app_environment.main[0].id
  resource_group_name          = azurerm_resource_group.main[0].name
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
    }

    min_replicas = var.min_instances
    max_replicas = var.max_instances
  }

  secret {
    name  = "database-url"
    value = "postgresql://goloyal_admin:${var.db_admin_password != "" ? var.db_admin_password : random_password.azure_db_password[0].result}@${azurerm_postgresql_flexible_server.main[0].fqdn}:5432/${var.app_name}?sslmode=require"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.main[0].admin_password
  }

  registry {
    server               = azurerm_container_registry.main[0].login_server
    username             = azurerm_container_registry.main[0].admin_username
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
