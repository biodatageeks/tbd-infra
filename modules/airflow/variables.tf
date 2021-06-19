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
  default = "tbd-airflow-logs"
  description = "Airflow logs location"
}