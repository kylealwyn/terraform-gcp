# Comment out if state is not already stored remotely
# After running `terraform apply`, uncomment this block
# and run `terraform init` to push your terraform state to the remote
# terraform {
#   backend "gcs" {
#     credentials = "../terraform.gcp.json"
#     bucket      = "example-tf-remote-state"
#     prefix      = "environment"
#   }
# }

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

module "network" {
  source                  = "../modules/networking"
  project_id              = module.project.project_id
  network_name            = local.project_name
  public_subnet_cidr      = var.vpc.public_subnet_cidr[local.env]
  private_subnet_cidr     = var.vpc.private_subnet_cidr[local.env]
  k8s_pods_cidr           = var.vpc.k8s_pods_cidr[local.env]
  k8s_pods_range_name     = var.vpc.k8s_pods_range_name
  k8s_services_cidr       = var.vpc.k8s_services_cidr[local.env]
  k8s_services_range_name = var.vpc.k8s_services_range_name
}

module "kubernetes" {
  source            = "../modules/kubernetes"
  name              = "${local.project_name}-cluster"
  project_id        = module.project.project_id
  region            = var.region
  network           = module.network.network_self_link
  subnetwork        = module.network.subnets_self_links[0]
  ip_range_pods     = var.vpc.k8s_pods_range_name
  ip_range_services = var.vpc.k8s_services_range_name
  machine_type      = var.k8s.machine_type[local.env]
  preemptible       = var.k8s.preemptible[local.env]
}

module "database" {
  source            = "../modules/database"
  project_id        = module.project.project_id
  region            = var.region
  name              = local.project_name
  tier              = var.sql.tier[local.env]
  availability_type = var.sql.availability_type[local.env]

  dependencies = [module.kubernetes.endpoint]
}

output "db_ip_address" {
  value = module.database.ip_address
}
