resource "helm_release" "postgres" {
  chart = "https://raw.githubusercontent.com/zalando/postgres-operator/master/charts/postgres-operator/postgres-operator-${var.chart_version}.tgz"
  name = "postgres-operator"
  namespace = "default"
  wait = true
  atomic = true
  timeout = 3600

  values = [
    file("${path.module}/resources/config.yaml")
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

resource "kubectl_manifest" "kubectl_create_cluster" {
  yaml_body = file("${path.module}/resources/manifest.yaml")
  depends_on = [helm_release.postgres]
}