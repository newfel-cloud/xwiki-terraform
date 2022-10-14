# These variables `only` work when we use ``packer init`` to test.
# Actually, in our terragrunt workflow, all variables have been set in modules/ec2/null_resource.packer_gen_image.local-exec
# Following variable only present for test ``packer init``
region         = "ap-southeast-1"
xwiki_img_name = "xwiki-img-test"
img_desc       = "XWiki image from Packer test"