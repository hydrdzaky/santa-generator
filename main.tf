terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}
provider "google" {
    project = "constant-jigsaw-414207"
    region = "us-central1"
    credentials = var.credskey
}
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com" // Service name
}
resource "google_cloud_run_v2_service" "default" {
  name     = "santa${var.tags}"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
 
  template {
    containers {
        image = "asia.gcr.io/constant-jigsaw-414207/secretsanta:${var.tags}"
    ports {
        container_port = 8080
      }
    }
  }
 depends_on = [
    google_project_service.cloud_run_api
  ]
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

variable "tags" {
  type=string   
} 
variable "credskey" {
  type=string   
} 