output "lb_domain_name" {
  description = "The DNS name of the load balancer."
  value       = module.load_balancer.lb_dns_name
}