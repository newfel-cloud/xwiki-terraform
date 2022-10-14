output "instance1" {
  value = google_compute_instance.xwiki_01t
}

output "instance2" {
  value = google_compute_instance.xwiki_02t
}

output "template" {
  value = module.google_compute_instance_template.self_link
}