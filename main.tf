provider "google" {
    project = "proyekdicoding-416705"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
 
  template {
    containers {
        image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
    ports {
        container_port = 80
      }
    }
  }
}
variable "tags" {
  type=string   
}  