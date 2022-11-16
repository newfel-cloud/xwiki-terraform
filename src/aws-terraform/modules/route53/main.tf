data "aws_route53_zone" "cienet" {
  name = var.route53_zone_name
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.cienet.zone_id
  name    = "xwiki-${random_id.random_dns_code.hex}"
  type    = "CNAME"
  ttl     = 300

  records = [
    "${var.lb_domain_name}"
  ]
}

resource "random_id" "random_dns_code" {
  byte_length = 4
}
