variable "region" {
  description = "AWS region where the provider will operate. The region must be set."
  type        = string
}

variable "enable_high_availability" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
}
variable "ssh_keypair_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
}

variable "base_img_id" {
  description = "Ubuntu, 20.04 LTS; ex: us-east-2 = ami-0d5bf08bc8017c83b ; "
  type        = string
}

variable "route53_zone_name" {
  description = "This is the name of the hosted zone. ex: cienet.cloud"
  type        = string
}

variable "internal_ips" {
  description = "A list of interal ip addresses will be created, The IP addresses must be \"inside\" the specified subnetwork."
  type        = list(string)
}