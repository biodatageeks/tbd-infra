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
  depends_on = [helm_release.kube-prometheus]
  name = "prometheus-pushgateway"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus-pushgateway"
  version = "1.7.1"
  namespace = "default"
  create_namespace = true
  values = [
    "${file("values-pushgateway.yaml")}"
  ]

}