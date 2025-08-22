terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  # Configure remote state storage (optional)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  service = each.value
  project = var.project_id

  disable_on_destroy = false
}

# VPC Network for private services
resource "google_compute_network" "main" {
  name                    = "goloyal-network"
  auto_create_subnetworks = true
  
  depends_on = [google_project_service.required_apis]
}

# Reserve IP range for private services
resource "google_compute_global_address" "private_ip_address" {
  name          = "goloyal-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

# Private connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_project_service.required_apis]
}

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgres" {
  name             = "goloyal-postgres-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier                        = "db-f1-micro"
    availability_type           = "ZONAL"
    disk_type                   = "PD_SSD"
    disk_size                   = 10
    disk_autoresize             = true
    disk_autoresize_limit       = 100

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      location                       = var.region
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
  }

  deletion_protection = false

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.required_apis
  ]
}

# Generate random suffix for database name
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create database
resource "google_sql_database" "goloyal_db" {
  name     = "goloyal"
  instance = google_sql_database_instance.postgres.name
}

# Create database user
resource "google_sql_user" "postgres_user" {
  name     = "goloyal_user"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

# Cloud Run service
resource "google_cloud_run_service" "goloyal_service" {
  name     = "goloyal-app"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/goloyal-app:latest"
        
        ports {
          container_port = 5000
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        env {
          name  = "DATABASE_URL"
          value = "postgresql://${google_sql_user.postgres_user.name}:${random_password.db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.goloyal_db.name}?sslmode=require"
        }

        env {
          name  = "PORT"
          value = "5000"
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
      }

      container_concurrency = 80
      timeout_seconds      = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"         = "0"
        "autoscaling.knative.dev/maxScale"         = "10"
        "run.googleapis.com/cloudsql-instances"    = google_sql_database_instance.postgres.connection_name
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/vpc-access-connector"  = google_vpc_access_connector.connector.id
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.required_apis]
}

# VPC Access Connector for Cloud Run to access private resources
resource "google_vpc_access_connector" "connector" {
  name          = "goloyal-connector"
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = "10.8.0.0/28"
  min_instances = 2
  max_instances = 3

  depends_on = [google_project_service.required_apis]
}

# Allow public access to Cloud Run service
resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_service.goloyal_service.location
  service  = google_cloud_run_service.goloyal_service.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# Custom domain mapping (optional)
# resource "google_cloud_run_domain_mapping" "default" {
#   location = var.region
#   name     = var.domain_name

#   metadata {
#     namespace = var.project_id
#   }

#   spec {
#     route_name = google_cloud_run_service.goloyal_service.name
#   }
# }