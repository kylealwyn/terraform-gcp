# Comment out if state is not already stored remotely
# After running `terraform apply`, uncomment this block
# and run `terraform init` to push your terraform state to the remote
terraform {
  backend "gcs" {
    bucket = "example-tf-remote-state"
    prefix = "root"
  }
}

provider "google" {
  region = var.region
}

locals {
  service_account_org_roles = [
    "billing.admin",
    "compute.networkAdmin",
    "compute.xpnAdmin",
    "container.hostServiceAgentUser",
    "resourcemanager.organizationAdmin",
    "resourcemanager.projectCreator",
  ]
}


module "root_project" {
  source = "../modules/project"

  org_id     = var.org_id
  billing_id = var.billing_id
  name       = var.root_project_name
  services   = var.services
}

# Create a bucket to store our Terraform state remotely
resource "google_storage_bucket" "state" {
  name     = var.remote_state_bucket_name
  project  = module.root_project.project_id
  location = "US"
}

module "service_account_tf" {
  source = "../modules/service_account"

  display_name = "Terraform Admin"
  account_id   = "terraform"
  project_id   = module.root_project.project_id
  roles = [
    "logging.admin",
    "storage.objectAdmin"
  ]
}

resource "google_organization_iam_member" "service_account_org_roles" {
  for_each = toset(local.service_account_org_roles)

  org_id = var.org_id
  role   = "roles/${each.value}"
  member = "serviceAccount:${module.service_account_tf.email}"
}

resource "google_compute_shared_vpc_host_project" "host_project" {
  project = module.root_project.project_id
}

resource "google_compute_network" "host_network" {
  name                    = "example-vpc-host"
  project                 = module.root_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "shared_network" {
  name    = "allow-ssh-and-icmp"
  project = module.root_project.project_id
  network = google_compute_network.host_network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3306"]
  }
}

output "host_project_id" {
  value = module.root_project.project_id
}

output "host_vpc_id" {
  value = google_compute_network.host_network.self_link
}
