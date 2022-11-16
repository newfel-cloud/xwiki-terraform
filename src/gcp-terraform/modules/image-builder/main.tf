locals {
  uuid             = split("-", uuid())[0]
  xwiki_image_name = join("-", ["${var.region}-xwiki-01t-img", "${local.uuid}"])
  img_desc         = "XWiki image from Packer which trigger by terraform"
}

resource "null_resource" "packer_gen_image" {
  triggers = {
    trigger = local.xwiki_image_name
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../../packer"
    command     = <<EOF
      packer init .
      packer build \
      -var "project_id=${var.project_id}" \
      -var "region=${var.region}" \
      -var "zone_code=${var.zone_code}" \
      -var "xwiki_img_name=${local.xwiki_image_name}" \
      -var "img_desc=${local.img_desc}" \
      -var "file_sources_tcp=${var.file_sources_tcp}" \
      -var "file_sources_hibernate=${var.file_sources_hibernate}" \
      -var "file_sources_startup_sh=${var.file_sources_startup_sh}" \
      -var "deploy_sh=${var.deploy_sh}" \
      .
    EOF
  }
}