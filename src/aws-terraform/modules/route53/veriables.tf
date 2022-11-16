variable "route53_zone_name" {
  description = "This is the name of the hosted zone. ex: cienet.cloud"
  type        = string
}

variable "lb_domain_name" {
  description = "The DNS name of the load balancer."
  type        = string
}