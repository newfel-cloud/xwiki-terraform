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
