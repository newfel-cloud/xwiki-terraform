resource "google_dns_record_set" "dns_record_default" {
  count = var.routing_policy_type == "default" ? 1 : 0

  project      = var.dns_project_id
  managed_zone = var.managed_zone
  name         = "xwiki-${random_id.random_dns_code_default.hex}.${var.domain_name}"
  type         = "A"
  ttl          = 300
  rrdatas = [
    var.lb_ip,
  ]
}

resource "random_id" "random_dns_code_default" {
  byte_length = 4
}

resource "google_dns_record_set" "dns_record_geo" {
  count = var.routing_policy_type == "geo" ? 1 : 0

  project      = var.dns_project_id
  managed_zone = var.managed_zone
  name         = "xwiki-${random_id.random_dns_code_geo.hex}.${var.domain_name}"
  type         = "A"
  ttl          = 300
  routing_policy { // after provider 4~
    geo {
      location = var.region
      rrdatas = [
        var.lb_ip,
      ]
    }
  }
}

resource "random_id" "random_dns_code_geo" {
  byte_length = 4
}