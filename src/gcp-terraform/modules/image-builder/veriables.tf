variable "region" {
  description = "The region will be created the image in, ex: asia-east1, us-west1"
  type        = string
}

variable "zone_code" {
  description = "The zone-code can be checked form https://cloud.google.com/compute/docs/regions-zones, ex: a, b, c"
  type        = string
  default     = "a"
}

variable "project_id" {
  description = "The project ID will be created the image in. ex: datadogtest-367504"
  type        = string
}

variable "file_sources_tcp" {
  description = "tcp file is used to packer provisioner file_sources"
  type        = string
  default     = "./script/tcp_gcp.xml" // packer directory
}

variable "file_sources_hibernate" {
  description = "hibernate file is used to packer provisioner file_sources"
  type        = string
  default     = "./script/hibernate_gcp.cfg.xml" // packer directory
}

variable "file_sources_startup_sh" {
  description = "startup.sh is used to packer provisioner file_sources"
  type        = string
  default     = "./script/startup.sh" // packer directory
}

variable "deploy_sh" {
  description = "deploy file is used to packer shell"
  type        = string
  default     = "./script/xwiki-manual-deploy-gcp.sh" // packer directory
}