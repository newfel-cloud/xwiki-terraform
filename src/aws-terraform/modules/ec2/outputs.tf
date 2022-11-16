output "template" {
  description = "Provides an EC2 launch template resource. Can be used to create instances or auto scaling groups."
  value       = aws_launch_template.xwiki
}

output "instance1" {
  description = "main ec2 instance 1"
  value       = module.ec2_instance_xwiki_01t
}

output "instance2" {
  description = "main ec2 instance 2"
  value       = module.ec2_instance_xwiki_02t
}