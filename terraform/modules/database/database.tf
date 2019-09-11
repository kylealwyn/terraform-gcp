variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "database_version" {
  type    = string
  default = "POSTGRES_11"
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "dependencies" {
  type    = list(string)
  default = []
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  name             = "${var.name}-instance-${random_id.suffix.hex}"
  database_version = var.database_version
  project          = var.project_id
  region           = var.region

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "public-internet"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "database" {
  project  = var.project_id
  instance = google_sql_database_instance.master.name
  name     = var.name
}

resource "google_sql_user" "root_user" {
  project  = var.project_id
  instance = google_sql_database_instance.master.name
  name     = "root"
  password = "root"
}

output "ip_address" {
  value = google_sql_database_instance.master.public_ip_address
}
