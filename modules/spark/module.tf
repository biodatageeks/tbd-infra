resource "helm_release" "spark-operator" {
  name = "spark-operator"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart = "spark-operator"
  version = "1.0.7"
  namespace = "default"
  create_namespace = true
}