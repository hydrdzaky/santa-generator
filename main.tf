provider "google" {
    project = "proyekdicoding-416705"
    region = "us-central1"
}
resource "google_container_registry" "registry" {
  project  = "proyekdicoding-416705"
  location = "US"
}
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
 
  template {
    containers {
        image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
        env {
            name = "PORT"
            value = "8081"
        }
        startup_probe {
            http_get {
            port = 8081
            }
        }
    }
  }
}
variable "tags" {
  type=string   
}  