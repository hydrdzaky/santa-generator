resource "google_cloud_run_service" "run_service" {
  name = "your_app"
  location = "us-central1"

  template {
	spec {
  	containers {
    	image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
  	}
	}
  }

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}
   depends_on = [google_project_service.run_api]
}
variable "tags" {
  type=string   
} 



# provider "google" {
#     project = "proyekdicoding-416705"
#     region = "us-central1"
# }
# resource "google_container_registry" "registry" {
#   project  = "proyekdicoding-416705"
#   location = "US"
# }
# resource "google_cloud_run_v2_service" "default" {
#   name     = "cloudrun-service"
#   location = "us-central1"
#   ingress = "INGRESS_TRAFFIC_ALL"
 
#   template {
#     containers {
#         image = "gcr.io/proyekdicoding-416705/secretsanta:${var.tags}"
#     ports {
#         container_port = 8080
#       }
#     }
#   }
# }
# variable "tags" {
#   type=string   
# } 