locals {
  uuid             = split("-", uuid())[0]
  xwiki_image_name = join("-", ["${var.region}-xwiki-01t-img", "${local.uuid}"])
  img_desc         = "XWiki image from Packer which trigger by terragrunt"
}

resource "null_resource" "packer_gen_image" {
  triggers = {
    trigger = local.xwiki_image_name
  }

  provisioner "local-exec" {
    working_dir = "../${var.env}/img"
    command     = <<EOF
      packer init .
      packer build \
      -var "project_id=${var.project_id}" \
      -var "region=${var.region}" \
      -var "zone=${var.region}-a" \
      -var "xwiki_img_name=${local.xwiki_image_name}" \
      -var "img_desc=${local.img_desc}" \
      .
    EOF
  }
}

data "google_compute_image" "ubuntu_latest" {
  depends_on = [
    null_resource.packer_gen_image
  ]
  family = "xwiki"
  //name   = "us-west1-xwiki-01t-img-cf86b0b9"
}

resource "google_compute_instance" "xwiki_01t" {
  name             = "g-${var.region}-a-xwiki-01t"
  zone             = "${var.region}-a"
  machine_type     = "c2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"
  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/${var.project_id}/global/images/${data.google_compute_image.ubuntu_latest.name}"
      size  = 30
    }
  }
  tags = [
    "g-${var.region}-a-xwiki-01t",
  ]
  network_interface {
    network    = "default"
    stack_type = "IPV4_ONLY"
    access_config {
      nat_ip = var.ips[0]
    }
    network_ip = "10.138.0.7"
  }
  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }
}

resource "google_compute_instance" "xwiki_02t" {
  name             = "g-${var.region}-b-xwiki-02t"
  zone             = "${var.region}-b"
  machine_type     = "c2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/beta/projects/${var.project_id}/global/images/${data.google_compute_image.ubuntu_latest.name}"
      size  = 30
    }
  }
  tags = [
    "g-${var.region}-b-xwiki-02t",
  ]
  network_interface {
    network    = "default"
    stack_type = "IPV4_ONLY"
    access_config {
      nat_ip = var.ips[1]
    }
    network_ip = "10.138.0.8"
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }
}

module "google_compute_instance_template" {
  source  = "terraform-google-modules/vm/google///modules/instance_template"
  version = "7.9.0"

  name_prefix      = "g-${var.region}-a-xwiki-01t-temp-"
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
}