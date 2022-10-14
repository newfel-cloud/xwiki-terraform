module "networking" {
  source = "../modules/networking"

  region = var.region
}

module "database" {
  source = "../modules/database"

  sg_map = module.networking.sg_map
}

module "efs" {
  source = "../modules/efs"

  subnets = module.networking.subnets
  sg_map  = module.networking.sg_map
}

module "ec2_instance" {
  source = "../modules/ec2"

  region = var.region
  env    = var.env
  ssh_keypair_name = var.ssh_keypair_name
  subnets          = module.networking.subnets
  sg_map           = module.networking.sg_map
  eips             = module.networking.eips
}

module "autoscaling" {
  source = "../modules/load-balancer"

  vpc          = module.networking.vpc
  subnets      = module.networking.subnets
  sg_map       = module.networking.sg_map
  region       = var.region
  instance_map = module.ec2_instance.instance_map
  template     = module.ec2_instance.template
}