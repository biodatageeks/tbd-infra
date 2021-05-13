variable "project_name" {
  type = string
  description = "Name of TBD project"
}

variable "location" {
  type = string
  description = "GCP location"
}

variable "logs_bucket" {
  type = string
  default = "tbd-2021-airflow-logs"
  description = "Airflow logs location"
}

variable "git_secret_path" {
  type = string
  description = "Private Git SSH key"
}