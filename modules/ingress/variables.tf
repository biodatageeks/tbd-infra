variable "cert_manager_version" {
  type = string
  default = "1.3.1"
}

variable "nginx_ingress_version" {
  type = string
  default = "0.9.1"
}

variable "prometheus_host" {
  type = string
  default = "prometheus.biodatageeks.org"
}

variable "grafana_host" {
  type = string
  default = "grafana.biodatageeks.org"
}

variable "airflow_host" {
  type = string
  default = "airflow.biodatageeks.org"
}

variable "acme_email" {
  type = string
  default = "zsibio@gmail.com"
}