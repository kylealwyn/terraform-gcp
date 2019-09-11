variable "name" {
  type = "string"
}

variable "project_id" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "network" {
  type = "string"
}

variable "subnetwork" {
  type = "string"
}

variable "ip_range_pods" {
  type = string
}

variable "ip_range_services" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "preemptible" {
  type = bool
}

resource "google_container_cluster" "primary" {
  name       = var.name
  project    = var.project_id
  location   = var.region
  network    = var.network
  subnetwork = var.subnetwork

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # ip_allocation_policy {
  #   cluster_secondary_range_name  = var.ip_range_pods
  #   services_secondary_range_name = var.ip_range_services
  # }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = true
    }

    kubernetes_dashboard {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.name}-pool"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name
  # max_pods_per_node = 50
  node_count = 1
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

# module "gke" {
#   source                     = "terraform-google-modules/kubernetes-engine/google"
#   project_id                 = var.project_id
#   name                       = var.name
#   region                     = var.region
#   network                    = var.network
#   subnetwork                 = var.subnetwork
#   ip_range_pods              = var.ip_range_pods
#   ip_range_services          = var.ip_range_services

#   http_load_balancing        = false
#   horizontal_pod_autoscaling = true
#   kubernetes_dashboard       = true
#   network_policy             = true
#   remove_default_node_pool   = true

#   node_pools = [
#     {
#       name               = "default-node-pool"
#       machine_type       = "n1-standard-2"
#       min_count          = 1
#       max_count          = 100
#       disk_size_gb       = 100
#       disk_type          = "pd-standard"
#       image_type         = "COS"
#       auto_repair        = true
#       auto_upgrade       = true
#       preemptible        = false
#       initial_node_count = 2
#     },
#   ]

#   node_pools_oauth_scopes = {
#     all = [
#       "https://www.googleapis.com/auth/devstorage.read_only",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }
# }
