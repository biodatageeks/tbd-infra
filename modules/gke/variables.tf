variable "project_name" {
  type = string
  description = "Name of TBD project"
}

variable "zone" {
  type = string
  description = "GCP zone"
}

variable "machine_type" {
  type = string
  description = "GCP machine type"
}

variable "max_node_count" {
  type = string
  description = "Maximum number of GKE nodes"
}