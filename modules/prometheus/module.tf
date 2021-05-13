resource "helm_release" "kube-prometheus" {
  name = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "14.0.1"
  namespace = "default"
  create_namespace = true
  wait = true
  atomic = true
  timeout = 3600

  values = [
    file("values-prometheus.yaml")
  ]
}

resource "helm_release" "prometheus-gateway" {
  depends_on = [helm_release.kube-prometheus]
  name = "prometheus-pushgateway"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus-pushgateway"
  version = "1.7.1"
  namespace = "default"
  create_namespace = true
  values = [
    file("values-pushgateway.yaml")
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

resource "kubectl_manifest" "spark-service-monitor" {
  yaml_body = file("${path.root}/examples/spark-operator/service-monitor.yaml")
}