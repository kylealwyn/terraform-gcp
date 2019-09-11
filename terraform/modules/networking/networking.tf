variable "project_id" {
  type = "string"
}

variable "network_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "k8s_pods_cidr" {
  type = string
}

variable "k8s_services_cidr" {
  type = string
}

variable "k8s_pods_range_name" {
  type = string
}

variable "k8s_services_range_name" {
  type = string
}

locals {
  public_subnet_name  = "${var.network_name}-subnet-public"
  private_subnet_name = "${var.network_name}-subnet-private"
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = var.network_name

  subnets = [
    {
      subnet_name   = local.public_subnet_name
      subnet_region = var.region
      subnet_ip     = var.public_subnet_cidr
    },
    {
      subnet_name           = local.private_subnet_name
      subnet_region         = var.region
      subnet_ip             = var.private_subnet_cidr
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    "${local.public_subnet_name}" = [
      {
        range_name    = var.k8s_pods_range_name
        ip_cidr_range = var.k8s_pods_cidr
      },
      {
        range_name    = var.k8s_services_range_name
        ip_cidr_range = var.k8s_services_cidr
      },
    ]
    "${local.private_subnet_name}" = []
  }
}

output "network_self_link" {
  value = module.vpc.network_self_link
}

output "subnets_self_links" {
  value = module.vpc.subnets_self_links
}

output "subnets_secondary_ranges" {
  value = module.vpc.subnets_secondary_ranges
}
