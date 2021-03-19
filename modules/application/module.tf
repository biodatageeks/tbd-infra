resource "google_storage_bucket" "application-storage" {
  name = var.project_name
  location = var.location
  force_destroy = true
}

data "google_iam_policy" "app-viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allAuthenticatedUsers",
    ]
  }
}

data "google_service_account" "tbd-lab" {
  account_id   = "tbd-lab"
}


resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.application-storage.name
  role = "roles/storage.admin"
  members = [
    "serviceAccount:${data.google_service_account.tbd-lab.email}",
  ]
}


resource "google_storage_bucket_iam_policy" "policy" {
  bucket = google_storage_bucket.application-storage.name
  policy_data = data.google_iam_policy.app-viewer.policy_data
}