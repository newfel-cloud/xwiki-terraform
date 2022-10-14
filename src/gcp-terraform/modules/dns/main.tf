resource "google_dns_record_set" "dns_record" {
  project      = "devops-356804" // CloudWork project
  managed_zone = "cienet-co"
  name         = "xwiki-${random_id.random_dns_code.hex}.cienet.co." // name field must end with trailing dot
  type         = "A"
  routing_policy { // after provider 4~
    geo {
      location = "us-west1"
      rrdatas = [
        var.lb_ip,
      ]
    }
  }
}

resource "random_id" "random_dns_code" {
  byte_length = 8
}