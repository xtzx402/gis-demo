terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "gis-demo"
  format        = "DOCKER"
}

resource "google_container_cluster" "primary" {
  name     = "gis-demo-cluster"
  location = var.zone

  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  deletion_protection = false
}

resource "google_secret_manager_secret" "version_secret" {
  secret_id = "app-version"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "version_value" {
  secret      = google_secret_manager_secret.version_secret.id
  secret_data = "blue"
}