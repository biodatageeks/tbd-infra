resource "google_storage_bucket" "application-storage" {
  name = var.project_name
  location = var.location
  force_destroy = true
}

resource "google_service_account" "tbd-lab" {
  account_id   = "tbd-lab"
  display_name = "Service account for TBD project"
}

resource "google_storage_bucket_iam_binding" "binding" {
  depends_on = [google_service_account.tbd-lab]
  bucket = google_storage_bucket.application-storage.name
  role = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.tbd-lab.email}",
  ]
}


resource "google_storage_bucket_iam_binding" "binding-app-viewer" {
  bucket = google_storage_bucket.application-storage.name
  role = "roles/storage.objectViewer"
  members = [
    "allAuthenticatedUsers",
  ]
}