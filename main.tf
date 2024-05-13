terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}
provider "google" {
    project = "proyekdicoding-416705"
    region = "us-central1"
    credentials = data.external.google_access_token.result
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

variable "google_credentials" {
  description = "Google Cloud Platform service account credentials"
  type        = string
  default     = "${var.creds}"
}
data "external" "google_access_token" {
  program = ["bash", "-c", "gcloud auth print-access-token --impersonate-service-account jenkins-gcloud@proyekdicoding-416705.iam.gserviceaccount.com"]
}