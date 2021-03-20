resource "helm_release" "spark-operator" {
  depends_on = []
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

