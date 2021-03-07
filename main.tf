module "project" {
  source   = "./modules/project"
  project_name  = var.project_name
  location = var.location
}