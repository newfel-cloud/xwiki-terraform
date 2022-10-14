module "network" {
  source = "../modules/networking"

  project_id = var.project_id
  region     = var.region
}

module "database" {
  source = "../modules/database"

  project_id = var.project_id
  region     = var.region
}

module "file_store" {
  source = "../modules/file-store"

  region = var.region
}

module "vm" {
  source = "../modules/vm"

  region          = var.region
  env             = var.env
  project_id      = var.project_id
  ips             = module.network.ips
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
}

module "load_balancer" {
  source = "../modules/load-balancer"

  vm1        = module.vm.instance1
  vm2        = module.vm.instance2
  project_id = var.project_id
  region     = var.region
  template   = module.vm.template
  lb_ip      = module.network.global_addresses[0]
}

# module "dns" {
#   source = "../modules/dns"
#   lb_ip  = module.network.lb_ip
# }