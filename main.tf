terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}
provider "google" {
    project = "proyekdicoding-416705"
}
resource "google_cloud_run_v2_service" "default" {
  name     = "app"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
 
  template {
    containers {
        image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
    ports {
        container_port = 8080
      }
    }
  }
  depends_on = [google_project_service.run_api]
}
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
variable "tags" {
  type=string   
} 