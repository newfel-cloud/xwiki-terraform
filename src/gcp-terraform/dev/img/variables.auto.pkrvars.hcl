# These variables `only` work when we use ``packer init`` to test.
# Actually, in our terraform workflow, all variables have been set or referenced in modules/ec2/null_resource.packer_gen_image.local-exec
# Following variable only present for test ``packer init``

project_id      = "henryleetest"
region          = "us-west1"
zone            = "us-west1-a"
xwiki_img_name  = "xwiki-img-henrytest"
img_desc        = "XWiki image from Packer"
