data "google_compute_image" "ubuntu_latest" {
  family = "xwiki"
  #name   = "us-west1-xwiki-01t-img-fe976d17"
}

resource "google_compute_instance" "xwiki_01t" {
  name             = "g-${var.region}-${var.zone_code1}-xwiki-01t"
  zone             = "${var.region}-${var.zone_code1}"
  machine_type     = "c2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"
  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/${var.project_id}/global/images/${data.google_compute_image.ubuntu_latest.name}"
      size  = 30
    }
  }
  tags = [
    "g-${var.region}-${var.zone_code1}-xwiki-01t",
  ]
  network_interface {
    network    = "default"
    stack_type = "IPV4_ONLY"
    access_config {
      //Access configurations, i.e. IPs via which this instance can be accessed via the Internet. 
      //Omit to ensure that the instance is not accessible from the Internet.
    }
    network_ip = var.internal_ips[0]
  }
  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  metadata_startup_script = var.startup_script
}

resource "google_compute_instance" "xwiki_02t" {
  name             = "g-${var.region}-${var.zone_code2}-xwiki-02t"
  zone             = "${var.region}-${var.zone_code2}"
  machine_type     = "c2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/${var.project_id}/global/images/${data.google_compute_image.ubuntu_latest.name}"
      size  = 30
    }
  }
  tags = [
    "g-${var.region}-${var.zone_code2}-xwiki-02t",
  ]
  network_interface {
    network    = "default"
    stack_type = "IPV4_ONLY"
    access_config {
      //Access configurations, i.e. IPs via which this instance can be accessed via the Internet. 
      //Omit to ensure that the instance is not accessible from the Internet.
    }
    network_ip = var.internal_ips[1]
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  metadata_startup_script = var.startup_script
}

module "google_compute_instance_template" {
  source  = "terraform-google-modules/vm/google///modules/instance_template"
  version = "7.9.0"

  name_prefix      = "g-${var.region}-${var.zone_code1}-xwiki-01t-temp-"
  machine_type     = "c2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"
  source_image     = "https://www.googleapis.com/compute/beta/projects/${var.project_id}/global/images/${data.google_compute_image.ubuntu_latest.name}"
  disk_size_gb     = 30
  disk_type        = "pd-balanced"
  tags = [
    "g-${var.region}-xwiki-autoscale",
  ]
  network         = "default"
  service_account = var.service_account

  startup_script = var.startup_script
}