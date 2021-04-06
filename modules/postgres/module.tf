resource "helm_release" "postgres" {
  chart = "../postgres-operator/charts/postgres-operator" # LOCAL_PATH
  name = "postgres-operator"
  namespace = "airflow-cluster1"

  values = [
    file("./modules/postgres/resources/config.yaml")
  ]
}