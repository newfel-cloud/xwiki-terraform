variable "vm1" {
  description = "Main compute instance main 1, it will be manage by instance-group."
  type        = any
}

variable "vm2" {
  description = "Main compute instance main 2, it will be manage by instance-group."
  type        = any
}

variable "project_id" {
  description = "The project ID will be created the auto-scale group in. ex: datadogtest-367504"
  type        = string
}

variable "region" {
  description = "The region will be created the instance-groups in, ex: asia-east1, us-west1"
  type        = string
}

variable "template" {
  description = "Self-link of instance template"
  type        = any
}

variable "lb_ip" {
  description = "The global_addresses ip for load-balancer."
  type        = string
}