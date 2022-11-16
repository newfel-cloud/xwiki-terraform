variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone_code" {
  type = string
}

variable "xwiki_img_name" {
  type = string
}

variable "img_desc" {
  type = string
}

variable "file_sources_tcp" {
  type    = string
  default = "./script/tcp_gcp.xml"
}

variable "file_sources_hibernate" {
  type    = string
  default = "./script/hibernate_gcp.cfg.xml"
}

variable "file_sources_startup_sh" {
  type    = string
  default = "./script/startup.sh"
}

variable "deploy_sh" {
  type    = string
  default = "./script/xwiki-manual-deploy-gcp.sh"
}