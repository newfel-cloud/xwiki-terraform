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
      image-id = "ami-07651f0c4c315a529"
    }
    owners = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["sources.amazon-ebs.xwiki-example"]

  provisioner "file" {
    sources     = ["../../packer/tcp.xml", "../../packer/xwiki.properties", "../../packer/hibernate.cfg.xml"]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "../../packer/xwiki-dev-deploy.sh"
  }

  post-processor "manifest" {
    output     = "xwiki-manifest.json"
    strip_path = true
  }
}
