variable "region" {
  type = string
}

variable "env" {
  description = "Such as dev, prod ..."
  type        = string
}

variable "ssh_keypair_name" {
  type = string
}

variable "subnets" {
  type = any
}

variable "sg_map" {
  type = map(any)
}

variable "eips" {
  type = list(any)
}
