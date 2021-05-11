resource "google_service_account" "airflow-service-account" {
  account_id   = "airflow-cluster1"
  display_name = "Service account for Airflow"
}

resource "google_storage_bucket" "airflow-logs-storage" {
  name = var.logs_bucket
  location = var.location
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "binding" {
  depends_on = [google_service_account.airflow-service-account]
  bucket = google_storage_bucket.airflow-logs-storage.name
  role = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.airflow-service-account.email}",
  ]
}

//wait = false -> https://github.com/hashicorp/terraform-provider-helm/issues/683
resource "helm_release" "kube-airflow" {
  name = "airflow-stable"
  repository = "https://airflow-helm.github.io/charts"
  chart = "airflow"
  version = "8.0.9"
  namespace = "default"
  wait = false

  values = [
    file("${path.module}/resources/config.yaml")
  ]
}