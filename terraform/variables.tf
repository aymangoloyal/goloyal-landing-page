variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "goloyal"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Azure-specific variables
variable "azure_location" {
  description = "The Azure region for resources"
  type        = string
  default     = "UK South"
}

variable "azure_resource_group_name" {
  description = "Azure resource group name (will be created if it doesn't exist)"
  type        = string
  default     = ""
}

# Database variables
variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_admin_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
  default     = ""
}

# Scaling variables
variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
  validation {
    condition     = var.min_instances >= 0
    error_message = "Minimum instances must be 0 or greater."
  }
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
  validation {
    condition     = var.max_instances > 0
    error_message = "Maximum instances must be greater than 0."
  }
}

variable "cpu_limit" {
  description = "CPU limit for instances"
  type        = string
  default     = "1000m"
  validation {
    condition     = can(regex("^[0-9]+m$", var.cpu_limit))
    error_message = "CPU limit must be in format '1000m'."
  }
}

variable "memory_limit" {
  description = "Memory limit for instances"
  type        = string
  default     = "2Gi"
  validation {
    condition     = can(regex("^[0-9]+[MG]i$", var.memory_limit))
    error_message = "Memory limit must be in format '2Gi' or '512Mi'."
  }
}

# Security variables
variable "enable_private_network" {
  description = "Enable private network for database"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Database backup retention in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}
