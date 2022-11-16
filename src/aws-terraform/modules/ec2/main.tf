data "aws_ami" "ubuntu_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.region}-xwiki-01t-img-*"]
  }

  # filter {
  #   name = "image-id"
  #   values = [
  #     "ami-03adc774b703afc55",
  #   ]
  # }
}

module "ec2_instance_xwiki_01t" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name          = "a-${var.region}-xwiki-01t"
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  // Network settings
  subnet_id         = var.subnets[0].id
  availability_zone = var.subnets[0].availability_zone
  vpc_security_group_ids = [
    var.sg_map["common"].security_group_id,
    //var.sg_map["remote"].security_group_id,
  ]
  // Configure storage
  root_block_device = [
    {
      volume_size = 30
      volume_type = "gp2"
    }
  ]
  associate_public_ip_address = true
  private_ip                  = var.internal_ips[0]

  user_data = templatefile(
    "${path.module}/user_data.tftpl",
    {
      db_hostname         = "${var.db_hostname}",
      efs_address         = "${var.efs_address}",
      xwiki_01_private_ip = "${var.internal_ips[0]}",
      xwiki_02_private_ip = "${var.internal_ips[1]}"
    }
  )
}

module "ec2_instance_xwiki_02t" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name          = "a-${var.region}-xwiki-02t"
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  // Network settings
  subnet_id         = var.subnets[1].id
  availability_zone = var.subnets[1].availability_zone
  vpc_security_group_ids = [
    var.sg_map["common"].security_group_id,
    //var.sg_map["remote"].security_group_id,
  ]
  // Configure storage
  root_block_device = [
    {
      volume_size = 30
      volume_type = "gp2"
    }
  ]
  associate_public_ip_address = true
  private_ip                  = var.internal_ips[1]

  user_data = templatefile(
    "${path.module}/user_data.tftpl",
    {
      db_hostname         = "${var.db_hostname}",
      efs_address         = "${var.efs_address}",
      xwiki_01_private_ip = "${var.internal_ips[0]}",
      xwiki_02_private_ip = "${var.internal_ips[1]}"
    }
  )
}

resource "aws_launch_template" "xwiki" {
  name_prefix   = "${var.region}-xwiki-01t-"
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.xlarge"
  key_name      = var.ssh_keypair_name
  vpc_security_group_ids = [
    var.sg_map["common"].security_group_id,
    //var.sg_map["remote"].security_group_id,
  ]
  user_data = base64encode(templatefile(
    "${path.module}/user_data.tftpl",
    {
      db_hostname         = "${var.db_hostname}",
      efs_address         = "${var.efs_address}",
      xwiki_01_private_ip = "${var.internal_ips[0]}",
      xwiki_02_private_ip = "${var.internal_ips[1]}"
    }
  ))
}

# resource "aws_eip_association" "xwiki_01t" {
#   instance_id   = module.ec2_instance_xwiki_01t.id
#   allocation_id = var.eips[0].id
# }

# resource "aws_eip_association" "xwiki_02t" {
#   instance_id   = module.ec2_instance_xwiki_02t.id
#   allocation_id = var.eips[1].id
# }