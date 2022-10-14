resource "google_service_account" "datadog_account" {
  account_id = "${var.name}-datadog"
}

resource "google_service_account_key" "datadog_key" {
  service_account_id = google_service_account.datadog_account.name
}

resource "google_project_iam_member" "datadog_viewer_permission" {
  project = google_service_account.datadog_account.project
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.datadog_account.email}"
}

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

resource "datadog_integration_gcp" "gcp_project_integration" {
  project_id     = jsondecode(base64decode(google_service_account_key.datadog_key.private_key))["project_id"]
  private_key    = jsondecode(base64decode(google_service_account_key.datadog_key.private_key))["private_key"]
  private_key_id = jsondecode(base64decode(google_service_account_key.datadog_key.private_key))["private_key_id"]
  client_email   = jsondecode(base64decode(google_service_account_key.datadog_key.private_key))["client_email"]
  client_id      = jsondecode(base64decode(google_service_account_key.datadog_key.private_key))["client_id"]

  depends_on = [google_project_iam_member.datadog_viewer_permission]
}

resource "datadog_api_key" "agent_key" {
  name = "${var.name}-datadog-terraform"
}