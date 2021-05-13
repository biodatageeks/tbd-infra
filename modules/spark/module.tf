resource "google_service_account" "spark-jobs-sa" {
  account_id   = "spark-jobs-sa"
  display_name = "Service account for Airflow"
}

resource "google_service_account_key" "spark-jobs-sa-key" {
  service_account_id = google_service_account.spark-jobs-sa.name
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "kubectl_manifest" "google-application-credentials" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: spark-jobs-sa-credentials
type: Opaque
data:
  credentials.json: ${google_service_account_key.spark-jobs-sa-key.private_key}
YAML
}

resource "google_storage_bucket" "jars-bucket" {
  name = var.jars_bucket
  location = var.location
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "binding" {
  depends_on = [google_service_account.spark-jobs-sa]
  bucket = google_storage_bucket.jars-bucket.name
  role = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.spark-jobs-sa.email}",
  ]
}

resource "helm_release" "spark-operator" {
  name = "spark-operator"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart = "spark-operator"
  version = "1.1.0"
  namespace = "default"
  create_namespace = true
  wait = true
  atomic = true
  timeout = 3600

  set {
    name = "serviceAccounts.spark.create"
    value = "true"
  }

  set {
    name = "serviceAccounts.spark.name"
    value = "spark"
  }
}