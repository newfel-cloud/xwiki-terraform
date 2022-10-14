variable "project_id" {
  description = "google cloud project id"
  type        = string
}

variable "region" {
  description = "google cloud region, ex: asia-east1"
  type        = string
}

variable "env" {
  description = "Such as dev, prod ..."
  type        = string
}

variable "vm_sa_email" {
  type = string
}