#==============================NETWORKING==============================#
module "global_addresses" {
  source  = "terraform-google-modules/address/google"
  version = "3.1.1"

  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL" // module default is INTERNAL. but resource default is EXTERNAL
  global       = true
  names = [
    "xwiki-${var.region}-lb-http-8080-ip",
  ]
}

module "xwiki_internal_addresses1" {
  source  = "terraform-google-modules/address/google"
  version = "3.1.1"

  project_id = var.project_id
  region     = var.region
  names = [
    "g-${var.region}-a-xwiki-01t-internal-static-ip",
    "g-${var.region}-b-xwiki-02t-internal-static-ip",
  ]
  addresses = [
    "10.138.0.7",
    "10.138.0.8",
  ]
}

module "xwiki_internal_addresses2" {
  source  = "terraform-google-modules/address/google"
  version = "3.1.1"

  project_id = var.project_id
  region     = var.region2
  names = [
    "g-${var.region2}-b-xwiki-01t-internal-static-ip",
    "g-${var.region2}-c-xwiki-02t-internal-static-ip",
  ]
  addresses = [
    "10.142.0.9",
    "10.142.0.10",
  ]
}

resource "google_compute_firewall" "rules" {
  name    = "xwiki-${var.region}-fw-http-8080"
  network = "default"
  allow {
    protocol = "tcp"
    ports = [
      "8080",
    ]
  }
  source_ranges = [
    "130.211.0.0/22", //Health check service ip
    "35.191.0.0/16",  //Health check service ip
    module.global_addresses.addresses[0],
    "59.120.29.30/32",    //company external public ip addresses
    "211.22.0.66/32",     //company external public ip addresses
    "125.227.137.224/30", //company external public ip addresses
  ]
  target_tags = [
    "g-${var.region}-a-xwiki-01t",
    "g-${var.region}-b-xwiki-02t",
    "g-${var.region}-xwiki-autoscale",
    "g-${var.region2}-b-xwiki-01t",
    "g-${var.region2}-c-xwiki-02t",
    "g-${var.region2}-xwiki-autoscale",
  ]
}
#==============================NETWORKING==============================#
#==============================DATABASE==============================#
resource "google_sql_database_instance" "xwiki_inatance" {
  name             = "xwiki-${var.region}-db"
  database_version = "MYSQL_8_0"
  region           = var.region
  settings {
    availability_type = var.availability_type
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

  deletion_protection = false                                                         // in order to destroy by using terraform destroy
  depends_on          = [google_service_networking_connection.private_vpc_connection] // must explicitly add a depends_on
  // if no depends_on, it will Error, failed to create instance because the network doesn't have at least 1 private services connection. 
  // Please see https://cloud.google.com/sql/docs/mysql/private-ip#network_requirements for how to create this connection.
}

# resource "google_sql_database_instance" "db_replica" {
#   name             = "xwiki-${var.region2}-db-replica"
#   database_version = "MYSQL_8_0"
#   region           = var.region2
#   settings {
#     availability_type = var.availability_type
#     location_preference {
#       zone           = "${var.region2}-b"
#     }
#     tier      = "db-custom-2-4096" //The machine type 
#     disk_type = "PD_SSD"
#     disk_size = 20
#     ip_configuration {
#       private_network = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/default"
#       ipv4_enabled    = false
#     }

#     activation_policy = "ALWAYS"
#   }
#   deletion_protection = false                                                         
#   depends_on          = [google_sql_database_instance.xwiki_inatance] 
#   master_instance_name = google_sql_database_instance.xwiki_inatance.name
#   replica_configuration {
#     failover_target = false
#   }
# }

resource "google_sql_database" "xwiki_inatance" {
  name      = "xwiki"
  charset   = "utf8"
  collation = "utf8_general_ci"
  instance  = google_sql_database_instance.xwiki_inatance.name
}

resource "google_sql_user" "user" {
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
#==============================DATABASE==============================#
#==============================FILE_STORE==============================#
module "file_store" {
  source = "../modules/file-store"

  region = var.region
}
#==============================FILE_STORE==============================#
#==============================BUILD_IMAGRE==============================#
module "build_image" {
  source = "../modules/image-builder"

  region           = var.region
  project_id       = var.project_id
  file_sources_tcp = "./script-multi/tcp_gcp.xml" // start form packer folder
}
#==============================BUILD_IMAGRE==============================#
#==============================VM_INSTANCES==============================#
module "vms_1" {
  source = "../modules/vm"

  depends_on = [
    module.build_image,
  ]
  region       = var.region
  project_id   = var.project_id
  internal_ips = module.xwiki_internal_addresses1.addresses
  service_account = {
    email = "${var.vm_sa_email}"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  startup_script = templatefile(
    "${path.module}/startup_script.tftpl",
    {
      db_ip               = "${google_sql_database_instance.xwiki_inatance.private_ip_address}",
      file_store_ip       = "${module.file_store.file_store_ip}",
      xwiki_01_private_ip = "${module.xwiki_internal_addresses1.addresses[0]}",
      xwiki_02_private_ip = "${module.xwiki_internal_addresses1.addresses[1]}",
      xwiki_03_private_ip = "${module.xwiki_internal_addresses2.addresses[0]}",
      xwiki_04_private_ip = "${module.xwiki_internal_addresses2.addresses[1]}"
    }
  )
}

module "vms_2" {
  source = "../modules/vm"

  depends_on = [
    module.build_image,
  ]
  region       = var.region2
  zone_code1   = "b"
  zone_code2   = "c" 
  project_id   = var.project_id
  internal_ips = module.xwiki_internal_addresses2.addresses
  service_account = {
    email = "${var.vm_sa_email}"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  startup_script = templatefile(
    "${path.module}/startup_script.tftpl",
    {
      db_ip               = "${google_sql_database_instance.xwiki_inatance.private_ip_address}",
      file_store_ip       = "${module.file_store.file_store_ip}",
      xwiki_01_private_ip = "${module.xwiki_internal_addresses1.addresses[0]}",
      xwiki_02_private_ip = "${module.xwiki_internal_addresses1.addresses[1]}",
      xwiki_03_private_ip = "${module.xwiki_internal_addresses2.addresses[0]}",
      xwiki_04_private_ip = "${module.xwiki_internal_addresses2.addresses[1]}"
    }
  )
}
#==============================VM_INSTANCES==============================#
#==============================LOAD_BALANCER==============================#
resource "google_compute_instance_group" "group_1" {
  name = "g-${var.region}-a-group-manual"
  named_port {
    name = "bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  zone = "${var.region}-a"
  instances = [
    module.vms_1.instance1.id
  ]
}

resource "google_compute_instance_group" "group_2" {
  name = "g-${var.region}-b-group-manual"
  named_port {
    name = "bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  zone = "${var.region}-b"
  instances = [
    module.vms_1.instance2.id
  ]
}

resource "google_compute_instance_group" "group_3" {
  name = "g-${var.region2}-b-group-manual"
  named_port {
    name = "bkend-port"
    port = 8080
  }
  zone = "${var.region2}-b"
  instances = [
    module.vms_2.instance1.id
  ]
}

resource "google_compute_instance_group" "group_4" {
  name = "g-${var.region2}-c-group-manual"
  named_port {
    name = "bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  zone = "${var.region2}-c"
  instances = [
    module.vms_2.instance2.id
  ]
}

resource "google_compute_region_instance_group_manager" "mig_1" {
  region = var.region
  base_instance_name = "g-${var.region}-group-autoscale"
  name   = "g-${var.region}-group-autoscale"
  version {
    instance_template = module.vms_1.template
  }
  named_port {
      name = "bkend-port" //same as google_compute_backend_service port_name
      port = 8080
  }
  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b",
  ]
  
  auto_healing_policies {
    health_check      = google_compute_health_check.xwiki_http_health_check.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_autoscaler" "autoscaler_1" {
  region = var.region
  name   = "${var.region}-autoscaler"
  target = google_compute_region_instance_group_manager.mig_1.id

  autoscaling_policy {
    max_replicas        = 10
    min_replicas        = 1
    cooldown_period     = 120
    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_region_instance_group_manager" "mig_2" {
  region = var.region2
  base_instance_name = "g-${var.region2}-group-autoscale"
  name   = "g-${var.region2}-group-autoscale"
  version {
    instance_template = module.vms_2.template
  }
  named_port {
      name = "bkend-port" //same as google_compute_backend_service port_name
      port = 8080
  }
  distribution_policy_zones = [
    "${var.region2}-b",
    "${var.region2}-c",
  ]
  
  auto_healing_policies {
    health_check      = google_compute_health_check.xwiki_http_health_check.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_autoscaler" "autoscaler_2" {
  region = var.region2
  name   = "${var.region2}-autoscaler"
  target = google_compute_region_instance_group_manager.mig_2.id

  autoscaling_policy {
    max_replicas        = 10
    min_replicas        = 1
    cooldown_period     = 120
    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_backend_service" "xwiki_lb_http_bkend_vm_auto" {
  name      = "g-xwiki-lb-http-bkend-vm-auto"
  port_name = "bkend-port"
  backend {
    group = google_compute_region_instance_group_manager.mig_1.instance_group
    max_utilization = 0.8
  }
  backend {
    group = google_compute_region_instance_group_manager.mig_2.instance_group
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.group_1.self_link
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.group_2.self_link
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.group_3.self_link
    max_utilization = 0.8
  }
  backend {
    group = google_compute_instance_group.group_4.self_link
    max_utilization = 0.8
  }
  health_checks = [ //only one
    google_compute_health_check.xwiki_http_health_check.self_link,
  ]
}

resource "google_compute_health_check" "xwiki_http_health_check" {
  name               = "xwiki-http-health-check"
  tcp_health_check {
    port         = 8080
  }
}

resource "google_compute_global_forwarding_rule" "xwiki_lb_http_frontend_ip" {
  name       = "g-lb-http-frontend-ip"
  ip_address = module.global_addresses.addresses[0]
  port_range = "8080-8080"
  target     = google_compute_target_http_proxy.xwiki_lb_http_8080_target_proxy.id
}

resource "google_compute_target_http_proxy" "xwiki_lb_http_8080_target_proxy" {
  name    = "xwiki-lb-http-8080-target-proxy"
  url_map = google_compute_url_map.xwiki_lb_http_8080.id
}

resource "google_compute_url_map" "xwiki_lb_http_8080" {
  default_service = google_compute_backend_service.xwiki_lb_http_bkend_vm_auto.id
  name            = "g-xwiki-lb-http-8080"
}
#==============================LOAD_BALANCER==============================#
#==============================DNS==============================#
module "dns" {
  source = "../modules/dns"

  depends_on = [
    google_compute_backend_service.xwiki_lb_http_bkend_vm_auto,
    google_compute_url_map.xwiki_lb_http_8080,
    google_compute_global_forwarding_rule.xwiki_lb_http_frontend_ip
  ]
  routing_policy_type = "default"
  region         = var.region
  dns_project_id = var.dns_project_id
  managed_zone   = var.managed_zone
  domain_name    = var.domain_name
  lb_ip          = module.global_addresses.addresses[0]
}
#==============================DNS==============================#