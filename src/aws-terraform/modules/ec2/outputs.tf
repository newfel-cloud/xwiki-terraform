output "template" {
  value = aws_launch_template.xwiki
}

output "instance_map" {
  value = {
    "instance1" = module.ec2_instance_xwiki_01t
    "instance2" = module.ec2_instance_xwiki_02t
  }
}