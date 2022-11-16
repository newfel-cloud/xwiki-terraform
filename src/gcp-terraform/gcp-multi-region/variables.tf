variable "project_id" {
  description = "google cloud project id where the resource will be created."
  type        = string
}

variable "region" {
  description = "google cloud region where the resource will be created. ex: us-west1"
  type        = string
}

variable "region2" {
  description = "google cloud region where the resource will be created. ex: us-east1"
  type        = string
}

variable "availability_type" {
  description = "The availability type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL)."
  type        = string
  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
    error_message = "Allowed values for type are \"REGIONAL\", \"ZONAL\"."
  }
}

variable "vm_sa_email" {
  description = "Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles."
  type        = string
}

variable "dns_project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "managed_zone" {
  description = "The name of the zone in which this record set will reside."
  type        = string
}

variable "domain_name" {
  description = "name field must end with trailing dot ex: xxx.yyy.co."
  type        = string
}
