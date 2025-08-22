output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.goloyal_service.status[0].url
}

output "database_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.postgres.connection_name
  sensitive   = true
}

output "database_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
  sensitive   = true
}

output "database_url" {
  description = "Full database connection URL"
  value       = "postgresql://${google_sql_user.postgres_user.name}:${random_password.db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.goloyal_db.name}?sslmode=require"
  sensitive   = true
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "vpc_connector_name" {
  description = "Name of the VPC access connector"
  value       = google_vpc_access_connector.connector.name
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}