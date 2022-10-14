output "vpc" {
  value = aws_default_vpc.default
}

output "subnets" {
  value = aws_default_subnet.default // aws_default_subnet.default use for_each to generate 
}

output "sg_map" {
  value = {
    "common" = module.security-group-common
    "remote" = module.security-group-remote
  }
}

output "eips" {
  value = [
    aws_eip.xwiki-01t-static-ip,
    aws_eip.xwiki-02t-static-ip
  ]
}
