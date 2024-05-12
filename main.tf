provider "google" {
    project = "Project Name"
    region = "us-central1"
}
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
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
}
variable "tags" {
  type=string   
}  