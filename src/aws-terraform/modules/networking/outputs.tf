output "vpc" {
  description = "the default AWS VPC in the current AWS Region."
  value       = aws_default_vpc.default
}

output "subnets" {
  description = " default subnets in the current region."
  value       = aws_default_subnet.default // aws_default_subnet.default use for_each to generate 
}

output "sg_map" {
  description = "security-group map"
  value = {
    "common" = module.security-group-common
  }
}

# output "eips" {
#   value = [
#     aws_eip.xwiki-01t-static-ip,
#     aws_eip.xwiki-02t-static-ip
#   ]
# }
