module "networking" {
  source = "../modules/networking"

  project_id         = var.project_id
  region             = var.region
  internal_addresses = var.internal_addresses
}

module "database" {
  source = "../modules/database"

  project_id        = var.project_id
  region            = var.region
  availability_type = var.availability_type
}

module "file_store" {
  source = "../modules/file-store"

  region = var.region
}

module "build_image" {
  source = "../modules/image-builder"

  region     = var.region
  project_id = var.project_id
}

module "vm" {
  source = "../modules/vm"

  depends_on = [
    module.build_image,
  ]
  region       = var.region
  project_id   = var.project_id
  internal_ips = module.networking.internal_ips
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
      db_ip               = "${module.database.db_ip}",
      file_store_ip       = "${module.file_store.file_store_ip}",
      xwiki_01_private_ip = "${module.networking.internal_ips[0]}",
      xwiki_02_private_ip = "${module.networking.internal_ips[1]}"
    }
  )
}

module "load_balancer" {
  source = "../modules/load-balancer"

  vm1        = module.vm.instance1
  vm2        = module.vm.instance2
  project_id = var.project_id
  region     = var.region
  template   = module.vm.template
  lb_ip      = module.networking.global_addresses[0]
}

module "dns" {
  source = "../modules/dns"

  depends_on = [
    module.load_balancer
  ]
  region         = var.region
  dns_project_id = var.dns_project_id
  managed_zone   = var.managed_zone
  domain_name    = var.domain_name
  lb_ip          = module.networking.global_addresses[0]
}