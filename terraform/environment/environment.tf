# Comment out if state is not already stored remotely
# After running `terraform apply`, uncomment this block
# and run `terraform init` to push your terraform state to the remote
terraform {
  backend "gcs" {
    credentials = "../terraform.gcp.json"
    bucket      = "example-tf-remote-state"
    prefix      = "environment"
  }
}


data "google_compute_network" "host_vpc" {
  name    = var.host_vpc_name
  project = var.host_project_id
}

provider "google" {
  credentials = "../terraform.gcp.json"
  region      = var.region
}

locals {
  env          = terraform.workspace
  project_name = "${var.company}-${terraform.workspace}"
}

module "project" {
  source     = "../modules/project"
  org_id     = var.org_id
  billing_id = var.billing_id
  name       = local.project_name
  services   = var.services
}

resource "google_compute_shared_vpc_service_project" "stack" {
  host_project    = var.host_project_id
  service_project = module.project.project_id
}

resource "google_compute_subnetwork" "public_subnet" {
  name             = local.project_name
  region           = var.region
  project          = var.host_project_id
  network          = data.google_compute_network.host_vpc.self_link
  ip_cidr_range    = var.vpc.public_subnet_cidr[local.env]
  enable_flow_logs = true

  secondary_ip_range {
    range_name    = var.vpc.k8s_pods_range_name
    ip_cidr_range = var.vpc.k8s_pods_cidr[local.env]
  }

  secondary_ip_range {
    range_name    = var.vpc.k8s_services_range_name
    ip_cidr_range = var.vpc.k8s_services_cidr[local.env]
  }

  depends_on       = [google_compute_shared_vpc_service_project.stack]
}

module "kubernetes" {
  source            = "../modules/kubernetes"
  name              = "${local.project_name}-cluster"
  host_project_id   = var.host_project_id
  project_id        = module.project.project_id
  project_number    = module.project.project_number
  region            = var.region

  network           = data.google_compute_network.host_vpc.self_link
  subnetwork        = google_compute_subnetwork.public_subnet.self_link
  ip_range_pods     = var.vpc.k8s_pods_range_name
  ip_range_services = var.vpc.k8s_services_range_name

  machine_type      = var.k8s.machine_type[local.env]
  preemptible       = var.k8s.preemptible[local.env]
}

# module "database" {
#   source            = "../modules/database"
#   project_id        = module.project.project_id
#   region            = var.region
#   name              = local.project_name
#   tier              = var.sql.tier[local.env]
#   availability_type = var.sql.availability_type[local.env]

#   dependencies = [module.kubernetes.endpoint]
# }

# output "db_ip_address" {
#   value = module.database.ip_address
# }
