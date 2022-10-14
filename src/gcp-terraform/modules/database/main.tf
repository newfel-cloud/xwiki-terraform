resource "google_sql_database_instance" "xwiki_inatance" {
  name             = "xwiki-${var.region}-db"
  root_password    = "1qaz2wsx"
  database_version = "MYSQL_8_0"
  region           = "us-west1"
  settings {
    availability_type = "REGIONAL" //high availability 
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
    location_preference {
      zone           = "${var.region}-a"
      secondary_zone = "${var.region}-b" // can't not pass terraform plan if version < 3.39
    }
    tier      = "db-custom-2-4096" //The machine type 
    disk_type = "PD_SSD"
    disk_size = 20
    ip_configuration {
      private_network = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/default"
      ipv4_enabled    = false
    }
  }

  deletion_protection = false // in order to destroy by using terraform destroy
  depends_on = [google_service_networking_connection.private_vpc_connection] // must explicitly add a depends_on
}

resource "google_sql_database" "xwiki" {
  name     = "xwiki"
  instance = google_sql_database_instance.xwiki_inatance.name
}

resource "google_sql_user" "user_1" {
  name     = "xwiki"
  instance = google_sql_database_instance.xwiki_inatance.name
  password = "xwiki"
}

resource "google_compute_global_address" "sql_address" {
  name          = "sql-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = "default"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network = "default"
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.sql_address.name,
  ]
}