variable "org_id" {
  type = string
}

variable "billing_id" {
  type = string
}

variable "name" {
  type = string
}

variable "services" {
  type = list(string)
}

resource "random_id" "project_id" {
  prefix      = "${var.name}-"
  byte_length = 4
}

# Create our application
resource "google_project" "proj" {
  org_id              = var.org_id
  billing_account     = var.billing_id
  name                = var.name
  project_id          = random_id.project_id.hex
  auto_create_network = false
}

# Enable our Google services
resource "google_project_service" "project_services" {
  for_each = toset(var.services)

  project                    = google_project.proj.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project.proj]
}

output "project_id" {
  value = google_project.proj.project_id
}

output "project_number" {
  value = google_project.proj.number
}
