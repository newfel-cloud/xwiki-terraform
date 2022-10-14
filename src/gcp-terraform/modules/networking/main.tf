module "global_addresses" {
  source  = "terraform-google-modules/address/google"
  version = "3.1.1"

  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL" // module default is INTERNAL. but resource default is EXTERNAL
  global       = true
  names = [
    "xwiki-${var.region}-lb-http-8080-ip",
  ]
}

module "xwiki_addresses" {
  source  = "terraform-google-modules/address/google"
  version = "3.1.1"

  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL" // module default is INTERNAL. but resource default is EXTERNAL
  names = [
    "g-${var.region}-xwiki-01t-static-ip",
    "g-${var.region}-xwiki-02t-static-ip",
  ]
}

resource "google_compute_firewall" "rules" {
  name    = "xwiki-${var.region}-fw-http-8080"
  network = "default"
  allow {
    protocol = "tcp"
    ports = [
      "8080",
    ]
  }
  source_ranges = [
    "130.211.0.0/22", //Health check service ip
    "35.191.0.0/16",  //Health check service ip
    module.global_addresses.addresses[0],
    "59.120.29.30/32",    //company external public ip addresses
    "211.22.0.66/32",     //company external public ip addresses
    "125.227.137.224/30", //company external public ip addresses
  ]
  target_tags = [
    "g-${var.region}-a-xwiki-01t",
    "g-${var.region}-b-xwiki-02t",
    "g-${var.region}-xwiki-autoscale",
  ]
}