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

resource "null_resource" "kubectl_create_cluster" {
  triggers = {
    manifest_contents = filemd5("${path.module}/resources/manifest.yaml")
  }

  provisioner "local-exec" {
    command = "gcp-login.sh && kubectl create -f ${path.module}/resources/manifest.yaml"
  }
  depends_on = [helm_release.postgres]
}