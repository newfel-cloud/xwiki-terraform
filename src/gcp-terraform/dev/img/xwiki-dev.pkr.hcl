packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.16"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "xwiki" {
  project_id            = "${var.project_id}"
  image_storage_locations = [
    "${var.region}",
  ]
  zone              = "${var.zone}"
  image_name        = "${var.xwiki_img_name}"
  image_description = "${var.img_desc}"
  image_labels = {
    developer = "andrewyang"
    team      = "gcps"
  }
  image_family        = "xwiki"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "root"
  network             = "default"
}

build {
  sources = ["sources.googlecompute.xwiki"]

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
