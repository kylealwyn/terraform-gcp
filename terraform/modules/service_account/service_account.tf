variable "account_id" {
  type = "string"
}

variable "display_name" {
  type = "string"
}

variable "roles" {
  type    = list(string)
  default = []
}

variable "project_id" {
  type = string
}

resource "google_service_account" "sa" {
  display_name = var.display_name
  account_id   = var.account_id
  project      = var.project_id
}

resource "google_project_iam_member" "project" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = "roles/${each.value}"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# resource "google_project_iam_binding" "project" {
#   for_each = var.roles

#   project = var.project_id
#   role    = "roles/editor"

#   members = [
#     "serviceAccount:${google_service_account.sa.email}",
#   ]
# }

# resource "google_service_account_iam_binding" "iam_binding" {


#   service_account_id = ""
#   role               = "roles/${each.value}"
# }

output "email" {
  value = google_service_account.sa.email
}
