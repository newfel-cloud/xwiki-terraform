locals {
  uuid        = split("-",uuid())[0]
  xwiki_image_name = join("-", ["${var.region}-xwiki-01t-img","${local.uuid}"])
  img_desc = "XWiki image from Packer which trigger by terragrunt or terraform"
}

resource "null_resource" "packer_gen_image" {
  triggers = {
    trigger = local.xwiki_image_name
  }

  provisioner "local-exec" {
    working_dir = "../${var.env}/img"
    command     = <<EOF
      packer init .
      packer build -var "region=${var.region}" -var "xwiki_img_name=${local.xwiki_image_name}" -var "img_desc=${local.img_desc}" .
    EOF
  }
}

data "aws_ami" "ubuntu_latest" {
  depends_on = [
    null_resource.packer_gen_image,
  ]

  most_recent = true
  # filter {
  #   name = "image-id"
  #   values = [
  #     "ami-04b56f187b1005708",
  #   ]
  # }
}

module "ec2_instance_xwiki_01t" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name = "a-${var.region}-xwiki-01t"
  ami  = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  // Network settings
  subnet_id         = var.subnets[0].id
  availability_zone = var.subnets[0].availability_zone
  vpc_security_group_ids = [
    var.sg_map.common.security_group_id,
    var.sg_map.remote.security_group_id,
  ]
  // Configure storage
  root_block_device = [
    {
      volume_size = 30
      volume_type = "gp2"
    }
  ]
  associate_public_ip_address = true
}

resource "aws_eip_association" "xwiki_01t" {
  instance_id   = module.ec2_instance_xwiki_01t.id
  allocation_id = var.eips[0].id
}

module "ec2_instance_xwiki_02t" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name = "a-${var.region}-xwiki-02t"
  ami  = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  // Network settings
  subnet_id         = var.subnets[1].id
  availability_zone = var.subnets[1].availability_zone
  vpc_security_group_ids = [
    var.sg_map.common.security_group_id,
    var.sg_map.remote.security_group_id,
  ]
  // Configure storage
  root_block_device = [
    {
      volume_size = 30
      volume_type = "gp2"
    }
  ]
  associate_public_ip_address = true
}

resource "aws_eip_association" "xwiki_02t" {
  instance_id   = module.ec2_instance_xwiki_02t.id
  allocation_id = var.eips[1].id
}

resource "aws_launch_template" "xwiki" {
  //name_prefix = "${var.region}-xwiki-01t-"
  name          = "${var.region}-xwiki-01t"
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  vpc_security_group_ids = [
    var.sg_map.common.security_group_id,
    var.sg_map.remote.security_group_id,
  ]
}