resource "google_storage_bucket" "application-storage" {
  name = var.project_name
  location = var.location
  force_destroy = true
}