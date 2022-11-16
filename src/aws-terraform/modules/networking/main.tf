resource "aws_default_vpc" "default" {

}

resource "aws_default_subnet" "default" {
  count             = length(data.aws_availability_zones.default.names)
  availability_zone = data.aws_availability_zones.default.names[count.index]
}

data "aws_availability_zones" "default" {

}

module "security-group-common" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name        = "s-ec2-sg-common-1"
  description = "Allow mysql, http, nfs port access, ssh"
  vpc_id      = aws_default_vpc.default.id
  ingress_with_cidr_blocks = [
    {
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      cidr_blocks = "${aws_default_vpc.default.cidr_block}"
    },
    {
      protocol    = "tcp"
      from_port   = 7800
      to_port     = 7800
      cidr_blocks = "${aws_default_vpc.default.cidr_block}"
    },
    {
      protocol    = "tcp"
      from_port   = 3306
      to_port     = 3306
      cidr_blocks = "${aws_default_vpc.default.cidr_block}"
    },
    {
      rule        = "http-8080-tcp"
      cidr_blocks = "${aws_default_vpc.default.cidr_block}"
    },
    {
      rule        = "http-8080-tcp"
      cidr_blocks = "59.120.39.30/32"
    },
    {
      rule        = "http-8080-tcp"
      cidr_blocks = "211.22.0.66/32"
    },
    {
      rule        = "http-8080-tcp"
      cidr_blocks = "125.227.137.224/30"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "59.120.39.30/32"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "211.22.0.66/32"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "125.227.137.224/30"
    },
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# resource "aws_eip" "xwiki-01t-static-ip" {
#   tags = {
#     Name = "a-${var.region}-xwiki-01t-static-ip"
#   }
# }

# resource "aws_eip" "xwiki-02t-static-ip" {
#   tags = {
#     Name = "a-${var.region}-xwiki-02t-static-ip"
#   }
# }

# module "security-group-remote" {
#   source  = "terraform-aws-modules/security-group/aws//modules/ssh"
#   version = "4.13.1"

#   name        = "s-ec2-sg-remote-1"
#   description = "Allow SSH port access"
#   vpc_id      = aws_default_vpc.default.id
#   ingress_cidr_blocks = [
#     "59.120.39.30/32",
#     "211.22.0.66/32",
#     "125.227.137.224/30"
#   ]
# }
