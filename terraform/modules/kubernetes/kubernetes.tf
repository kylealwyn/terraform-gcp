variable "name" {
  type = "string"
}

variable "host_project_id" {
  type = "string"
}


variable "project_id" {
  type = "string"
}

variable "project_number" {
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

resource "google_project_iam_member" "host_agent" {
  project = var.host_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "compute_subnetworks" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"

  members  = [
    "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:${var.project_number}@cloudservices.gserviceaccount.com"
  ]
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

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }
  }

  depends_on = [google_project_iam_member.host_agent]
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.name}-pool"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name
  # max_pods_per_node = 50
  node_count = 2
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

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}
