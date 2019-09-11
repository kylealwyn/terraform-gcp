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

resource "google_organization_iam_member" "org_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${module.service_account_tf.email}"
}

resource "google_organization_iam_member" "project_creator" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${module.service_account_tf.email}"
}

resource "google_billing_account_iam_member" "binding" {
  billing_account_id = var.billing_id
  role               = "roles/billing.admin"
  member             = "serviceAccount:${module.service_account_tf.email}"
}
