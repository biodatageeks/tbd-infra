resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow-cluster1"
  }
}

resource "google_service_account" "airflow-service-account" {
  account_id   = "airflow-cluster1"
  display_name = "Service account for Airflow"
}

resource "google_storage_bucket" "airflow-logs-storage" {
  name = "airflow-cluster1"
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

resource "helm_release" "kube-airflow" {
  name = "airflow-stable"
  repository = "https://airflow-helm.github.io/charts"
  chart = "airflow"
  version = "8.0.9"
  namespace = "airflow-cluster1"
  wait = false

  values = [
    file("./modules/airflow/config.yaml")
  ]
}