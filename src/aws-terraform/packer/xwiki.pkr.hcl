packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "xwiki-example" {
  region = "${var.region}"

  instance_type   = "t2.xlarge"
  ami_name        = "${var.xwiki_img_name}"
  ami_description = "${var.img_desc}"
  tags = {
    developer = "henryLee"
    team      = "aws"
  }
  ami_regions = [
    "${var.region}",
  ]

  source_ami_filter {
    filters = {
      image-id = "${var.base_img_id}" // Ubuntu, 20.04 LTS

    }
    owners = ["amazon"]
  }
  ssh_username = "ubuntu" // lease login as the user "ubuntu" rather than the user "root".
}

build {
  sources = ["sources.amazon-ebs.xwiki-example"]

  provisioner "file" {
    sources     = [
      "../script/tcp_aws.xml", 
      "../script/hibernate_aws.cfg.xml",
      "../script/startup.sh",
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "../script/xwiki-manual-deploy-aws.sh"
  }

  post-processor "manifest" {
    output     = "xwiki-manifest.json"
    strip_path = true
  }
}
