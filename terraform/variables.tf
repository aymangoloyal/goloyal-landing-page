variable "cloud_provider" {
  description = "Cloud provider to deploy to (azure or gcp)"
  type        = string
  validation {
    condition     = contains(["azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be either 'azure' or 'gcp'."
  }
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "goloyal"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
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
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "cpu_limit" {
  description = "CPU limit for instances"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for instances"
  type        = string
  default     = "2Gi"
}
