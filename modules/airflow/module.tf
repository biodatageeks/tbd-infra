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

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "kubectl_manifest" "git_secret" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: airflow-ssh-git-secret
type: Opaque
data:
  id_rsa: "${base64encode(file(var.git_secret_path))}"
YAML
}

//wait = false -> https://github.com/hashicorp/terraform-provider-helm/issues/683
resource "helm_release" "kube-airflow" {
  name = "airflow-stable"
  repository = "https://airflow-helm.github.io/charts"
  chart = "airflow"
  version = "8.4.1"
  namespace = "default"
  wait = false

  values = [
    file("${path.module}/resources/config.yaml")
  ]
  depends_on = [kubectl_manifest.git_secret]
}