variable "project_name" {
  type = string
  description = "Name of TBD project"
}

variable "location" {
  type = string
  description = "GCP location"
}

variable "machine_type" {
  type = string
  description = "GCP machine type"
}

variable "max_node_count" {
  type = string
  description = "Maximum number of GKE nodes"
}