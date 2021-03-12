resource "helm_release" "kube-prometheus" {
  name = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "14.0.1"
  namespace = "default"
  create_namespace = true

  set {
    name = "prometheus.global.scrape_interval"
    value = "10s"
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