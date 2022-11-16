module "networking" {
  source = "../modules/networking"

}

module "database" {
  source = "../modules/database"

  enable_high_availability = var.enable_high_availability
  sg_map                   = module.networking.sg_map
}

module "efs" {
  source = "../modules/efs"

  subnet = module.networking.subnets[0]
  sg_map = module.networking.sg_map
}

module "build_image" {
  source = "../modules/image-builder"

  region      = var.region
  base_img_id = var.base_img_id
}

module "ec2_instance" {
  source = "../modules/ec2"

  depends_on = [
    module.build_image
  ]
  region           = var.region
  ssh_keypair_name = var.ssh_keypair_name
  subnets          = module.networking.subnets
  sg_map           = module.networking.sg_map
  internal_ips     = var.internal_ips
  //eips             = module.networking.eips
  db_hostname = module.database.db_hostname
  efs_address = module.efs.efs_address
}

module "load_balancer" {
  source = "../modules/load-balancer"

  vpc      = module.networking.vpc
  subnets  = module.networking.subnets
  sg_map   = module.networking.sg_map
  region   = var.region
  ec2_1    = module.ec2_instance.instance1
  ec2_2    = module.ec2_instance.instance2
  template = module.ec2_instance.template
}

module "dns" {
  source = "../modules/route53"

  route53_zone_name = var.route53_zone_name
  lb_domain_name    = module.load_balancer.lb_domain_name
}