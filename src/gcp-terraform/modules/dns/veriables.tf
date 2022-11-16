variable "dns_project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "managed_zone" {
  description = "The name of the zone in which this record set will reside. ex: xwiki-cienet-co"
  type        = string
}

variable "domain_name" {
  description = "name field must end with trailing dot ex: xwiki.cienet.co."
  type        = string
}

variable "region" {
  description = "The region will be used to routing_policy geo, ex: asia-east1, us-west1"
  type        = string
}
variable "lb_ip" {
  description = "The global_addresses ip for load-balancer."
  type        = string
}

variable "routing_policy_type" {
  description = "The routing policy type of the Cloud DNS, default or wrr (Weighted Round Robin) or geo (Geo-Based) ."
  type        = string
  validation {
    condition     = contains(["default", "wrr", "geo"], var.routing_policy_type)
    error_message = "Allowed values for type are \"default\", \"wrr\", \"geo\"."
  }
  default = "geo"
}