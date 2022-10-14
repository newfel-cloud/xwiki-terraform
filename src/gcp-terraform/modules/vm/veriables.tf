variable "region" {
  description = "google cloud region, ex: asia-east1"
  type        = string
}

variable "env" {
  description = "Such as dev, prod ..."
  type        = string
}

variable "project_id" {
  description = "google cloud project id"
  type        = string
}

variable "ips" {
  type = list(string)
}

variable "service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type = object({
    email  = string
    scopes = set(string)
  })
}