module "application" {
  source   = "./modules/application"
  project_name = var.project_name
  location = var.location
}

module "gke" {
  source   = "./modules/gke"
  project_name  = var.project_name
  zone = var.zone
  machine_type = var.machine_type
  max_node_count = var.max_node_count
  depends_on = [module.application]
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host = module.gke.endpoint
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = module.gke.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host = "http://${module.gke.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.gke.endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
  token                  = data.google_client_config.default.access_token
  load_config_file       = false
  apply_retry_count = 15
}

module "postgres" {
  source = "./modules/postgres"
  depends_on = [module.gke]
}

module "spark" {
  source   = "./modules/spark"
  depends_on = [module.gke]
  location = var.location
  jars_bucket = "tbd-2021l-123-jars-storage"
}

module "airflow" {
  source = "./modules/airflow"
  depends_on = [module.gke, module.postgres, module.spark]
  project_name = var.project_name
  location = var.location
  git_secret_path = "<PATH_TO_PRIVATE_SSH_KEY_FILE>"
}

module "prometheus" {
  source   = "./modules/prometheus"
  depends_on = [module.gke]
}

module "ingress" {
  source   = "./modules/ingress"
  depends_on = [module.gke]
}