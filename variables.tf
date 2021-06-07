variable "project_name" {
  type = string
  description = "Name of TBD project"
}

variable "location" {
  type = string
  description = "GCP location"
}

variable "zone" {
  type = string
  description = "GCP zone"
}

variable "machine_type" {
  type = string
  default = "e2-standard-2"
  description = "GCP machine type"
}

variable "max_node_count" {
  type = string
  description = "Maximum number of GKE nodes"
}

variable "pool_preemptible" {
  type = bool
  default = true
  description = "Pool preemptible t/f"
}