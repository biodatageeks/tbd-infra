module "gke" {
  source   = "./modules/gke"
  project_name  = var.project_name
  zone = var.zone
  machine_type = var.machine_type
  max_node_count = var.max_node_count
}


module "spark" {
  source   = "./modules/spark"
  endpoint = module.gke.endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}

module "prometheus" {
  source   = "./modules/prometheus"
  endpoint = module.gke.endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}

module "application" {
  source   = "./modules/application"
  project_name = var.project_name
  location = var.location
}
