resource "helm_release" "postgres" {
  chart = var.postgres_chart_path
  name = "postgres-operator"
  namespace = "default"
  wait = false

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