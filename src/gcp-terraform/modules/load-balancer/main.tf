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

resource "google_compute_health_check" "health_check" {
  name = "xwiki-healthcheck-http-8080"
  tcp_health_check {
    port = "8080"
  }
}

resource "google_compute_region_instance_group_manager" "img" {
  name               = "g-${var.region}-group-autoscale"
  base_instance_name = "g-${var.region}-group-autoscale"
  version {
    instance_template = var.template
  }
  region = var.region
  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b"
  ]
  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.id
    initial_delay_sec = 300
  }
  named_port {
    name = "${var.region}-bkend-port" //same as google_compute_backend_service port_name
    port = 8080
  }
  target_size = 1
}

resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "autoscaler"
  target = google_compute_region_instance_group_manager.img.id
  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 1
    cooldown_period = 120

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_backend_service" "xwiki_lb_http_bkend_vm_auto" {
  name      = "g-${var.region}-xwiki-lb-http-bkend-vm-auto"
  port_name = "${var.region}-bkend-port"
  backend {
    group = google_compute_region_instance_group_manager.img.instance_group
  }
  backend {
    group = google_compute_instance_group.group_1.self_link
  }
  backend {
    group = google_compute_instance_group.group_2.self_link
  }

  health_checks = [
    google_compute_health_check.health_check.id,
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