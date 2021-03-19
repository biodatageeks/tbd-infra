resource "helm_release" "kube-prometheus" {
  name = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "14.0.1"
  namespace = "default"
  create_namespace = true

  values = [
    "${file("values-prometheus.yaml")}"
  ]
}

resource "helm_release" "prometheus-gateway" {
  name = "prometheus-pushgateway"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus-pushgateway"
  version = "1.7.1"
  namespace = "default"
  create_namespace = true

  set {
    name = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name = "serviceMonitor.namespace"
    value = "default"
  }
  values = [
    "${file("values-pushgateway.yaml")}"
  ]

}

data "google_client_config" "default" {}
provider "helm" {
  kubernetes {
    host = var.endpoint
    token = "${data.google_client_config.default.access_token}"
    cluster_ca_certificate = var.cluster_ca_certificate

  }
}