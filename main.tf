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

 data "google_iam_policy" "noauth" {
   binding {
     role = "roles/run.invoker"
     members = ["allUsers"]
   }
 }

 resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_v2_service.default.location
   project     = google_cloud_run_v2_service.default.project
   service     = google_cloud_run_v2_service.default.name

   policy_data = data.google_iam_policy.noauth.policy_data
 }
variable "tags" {
  type=string   
}  