provider "google" {
    project = "proyekdicoding-416705"
    region = "us-central1"
}
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv-cicd"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
        ports {
          container_port = 8080
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
variable "tags" {
  type=string   
}  