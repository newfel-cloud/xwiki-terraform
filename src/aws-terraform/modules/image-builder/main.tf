locals {
  uuid             = split("-", uuid())[0]
  xwiki_image_name = join("-", ["${var.region}-xwiki-01t-img", "${local.uuid}"])
  img_desc         = "XWiki image from Packer which trigger by terragrunt or terraform"
  base_img_id      = var.base_img_id
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
      -var "region=${var.region}" \
      -var "xwiki_img_name=${local.xwiki_image_name}" \
      -var "img_desc=${local.img_desc}" \
      -var "base_img_id=${local.base_img_id}" \
      .
    EOF
  }
}