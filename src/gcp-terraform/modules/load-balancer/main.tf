resource "google_compute_instance_group" "group_1" {
  name = "g-${var.region}-a-group-manual"
  named_port {
    name = "${var.region}-bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  zone = "${var.region}-a"
  instances = [
    var.vm1.id,
  ]
}

resource "google_compute_instance_group" "group_2" {
  name = "g-${var.region}-b-group-manual"
  named_port {
    name = "${var.region}-bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  zone = "${var.region}-b"
  instances = [
    var.vm2.id,
  ]
}

module "img" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "7.9.0"

  project_id        = var.project_id
  mig_name          = "g-${var.region}-group-autoscale"
  hostname          = "g-${var.region}-group-autoscale"
  instance_template = var.template
  region            = var.region
  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b"
  ]
  autoscaling_enabled = true
  max_replicas        = 10
  min_replicas        = 1
  cooldown_period     = 120
  autoscaler_name     = "autoscaler"
  autoscaling_cpu = [
    {
      target = 0.5
    },
  ]
  health_check_name = "xwiki-healthcheck-http-8080"
  health_check = {
    type                = "tcp"
    port                = 8080
    proxy_header        = "NONE"
    request             = ""
    response            = ""
    check_interval_sec  = 5
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    check_interval_sec  = 10
    timeout_sec         = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    host                = ""
    initial_delay_sec   = 30
    request_path        = "/"
  }
  named_ports = [
    {
      name = "${var.region}-bkend-port" //same as google_compute_backend_service port_name
      port = 8080
    },
  ]
}

resource "google_compute_backend_service" "xwiki_lb_http_bkend_vm_auto" {
  name      = "g-${var.region}-xwiki-lb-http-bkend-vm-auto"
  port_name = "${var.region}-bkend-port"
  backend {
    group           = module.img.instance_group
    max_utilization = 0.8
  }
  backend {
    group           = google_compute_instance_group.group_1.self_link
    max_utilization = 0.8
  }
  backend {
    group           = google_compute_instance_group.group_2.self_link
    max_utilization = 0.8
  }
  health_checks = [
    module.img.health_check_self_links[0],
  ]
}

resource "google_compute_global_forwarding_rule" "xwiki_lb_http_frontend_ip" {
  name       = "g-${var.region}-lb-http-frontend-ip"
  ip_address = var.lb_ip
  port_range = "8080-8080"
  target     = google_compute_target_http_proxy.xwiki_lb_http_8080_target_proxy.id
}

resource "google_compute_target_http_proxy" "xwiki_lb_http_8080_target_proxy" {
  name    = "xwiki-lb-http-8080-target-proxy"
  url_map = google_compute_url_map.xwiki_lb_http_8080.id
}

resource "google_compute_url_map" "xwiki_lb_http_8080" {
  default_service = google_compute_backend_service.xwiki_lb_http_bkend_vm_auto.id
  name            = "g-${var.region}-xwiki-lb-http-8080"
}

# module "gce-lb-http" {
#   source            = "GoogleCloudPlatform/lb-http/google"
#   version           = "6.3.0"

#   project           = var.project_id
#   name              = "g-${var.region}-xwiki-lb-http-8080"
#   address           = var.lb_ip
#   backends = {
#     default = {
#       description                     = null
#       protocol                        = "HTTP"
#       port                            = 8080
#       port_name                       = "${var.region}-bkend-port"
#       timeout_sec                     = 10
#       enable_cdn                      = false
#       custom_request_headers          = null
#       custom_response_headers         = null
#       security_policy                 = null

#       connection_draining_timeout_sec = null
#       session_affinity                = null
#       affinity_cookie_ttl_sec         = null

#       health_check = {
#         type                = "tcp"
#         initial_delay_sec   = 300
#         check_interval_sec  = 5
#         healthy_threshold   = 2
#         timeout_sec         = 5
#         unhealthy_threshold = 2
#         response            = ""
#         proxy_header        = "NONE"
#         port                = 8080
#         request             = ""
#         request_path        = "/"
#         host                = "localhost"
#         logging             = null
#       }

#       log_config = {
#         enable = true
#         sample_rate = 1.0
#       }

#       groups = [
#         {
#           group                        = module.img.instance_group
#           balancing_mode               = null
#           capacity_scaler              = null
#           description                  = null
#           max_connections              = null
#           max_connections_per_instance = null
#           max_connections_per_endpoint = null
#           max_rate                     = null
#           max_rate_per_instance        = null
#           max_rate_per_endpoint        = null
#           max_utilization              = null
#         },
#         {
#           group                        = google_compute_instance_group.group_1.self_link
#           balancing_mode               = null
#           capacity_scaler              = null
#           description                  = null
#           max_connections              = null
#           max_connections_per_instance = null
#           max_connections_per_endpoint = null
#           max_rate                     = null
#           max_rate_per_instance        = null
#           max_rate_per_endpoint        = null
#           max_utilization              = null
#         },
#         {
#           group                        = google_compute_instance_group.group_2.self_link
#           balancing_mode               = null
#           capacity_scaler              = null
#           description                  = null
#           max_connections              = null
#           max_connections_per_instance = null
#           max_connections_per_endpoint = null
#           max_rate                     = null
#           max_rate_per_instance        = null
#           max_rate_per_endpoint        = null
#           max_utilization              = null
#         },
#       ]

#       iap_config = {
#         enable               = false
#         oauth2_client_id     = null
#         oauth2_client_secret = null
#       }
#     }
#   }
# }