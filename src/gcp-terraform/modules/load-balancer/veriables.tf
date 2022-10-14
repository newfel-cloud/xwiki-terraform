variable "vm1" {
  type = any
}

variable "vm2" {
  type = any
}

variable "project_id" {
  description = "google cloud project id"
  type        = string
}

variable "region" {
  description = "google cloud region, ex: asia-east1"
  type        = string
}

variable "template" {
  type = any
}

variable "lb_ip" {
  type = string
}