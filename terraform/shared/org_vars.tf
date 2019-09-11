
variable "org_id" {
  default = "44898416854"
}

variable "billing_id" {
  default = "017D8A-FB0A5D-1E6C6E"
}

variable "company" {
  default = "example"
}

variable "region" {
  default = "us-west1"
}

variable "root_project_name" {
  default = "root"
}

variable "remote_state_bucket_name" {
  default = "example-tf-remote-state"
}

variable "services" {
  default = [
    "bigquery-json.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "deploymentmanager.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]
}
