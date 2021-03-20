
resource "google_project_service" "tbd-service-iam" {
  project = var.project_name
  service = "iam.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "tbd-service-gke" {
  project = var.project_name
  service = "container.googleapis.com"

  disable_dependent_services = true
}

//resource "google_service_account" "tbd-lab" {
//  account_id   = "tbd-lab"
//  display_name = "Service account for TBD project"
//}



resource "google_container_cluster" "primary" {
  name     = "tbd-gke-cluster"
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

data "google_service_account" "tbd-lab" {
  account_id   = "tbd-lab"
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "tbd-lab-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = var.max_node_count
  }

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.tbd-lab.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "example2" {
  metadata {
    name = "terraform-example"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "terraform@tbd-group-997-admin.iam.gserviceaccount.com"
    api_group = "rbac.authorization.k8s.io"
  }
}