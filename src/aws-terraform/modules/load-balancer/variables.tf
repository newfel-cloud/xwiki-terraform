variable "region" {
  type = string
}

variable "vpc" {
  type = any
}

variable "subnets" {
  type = any
}

variable "sg_map" {
  type = map(any)
}

variable "instance_map" {
  type = map(any)
}

variable "template" {
  type = any
}