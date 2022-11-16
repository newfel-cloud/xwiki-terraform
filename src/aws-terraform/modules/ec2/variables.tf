variable "region" {
  default = "The region is used to naming style. ex: us-east-2"
  type    = string
}

variable "ssh_keypair_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
}

variable "subnets" {
  description = " default subnets in the current region."
  type        = any
}

variable "sg_map" {
  description = "security-group map"
  type        = map(any)
}

variable "db_hostname" {
  description = "The hostname of the RDS instance."
  type        = string
}
variable "efs_address" {
  description = "Address at which the file system may be mounted via the mount target."
  type        = string
}

variable "internal_ips" {
  description = "A list of interal ip addresses will be created, The IP addresses must be \"inside\" the specified subnetwork."
  type        = list(string)
}

# variable "eips" {
#   type = list(any)
# }