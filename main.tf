module "gke" {
  source   = "./modules/gke"
  project_name  = var.project_name
  location = var.location
  machine_type = var.machine_type
}


module "spark" {
  source   = "./modules/spark"
}