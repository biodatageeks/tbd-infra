resource "helm_release" "spark-operator" {
  name = "spark-operator"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart = "spark-operator"
  version = "1.0.7"
  namespace = "default"
  create_namespace = true

  set {
    name = "serviceAccounts.spark.create"
    value = "true"
  }

  set {
    name = "serviceAccounts.spark.name"
    value = "spark"
  }
}

data "google_client_config" "default" {}
provider "helm" {
  kubernetes {
    host = var.endpoint
    token = "${data.google_client_config.default.access_token}"
    cluster_ca_certificate = var.cluster_ca_certificate

  }
}