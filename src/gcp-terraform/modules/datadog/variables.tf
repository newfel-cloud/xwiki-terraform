variable "datadog_api_key" {
  type        = string
  description = "Datadog API Key used to create resources."
  sensitive   = true
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog App Key."
  sensitive   = true
}

variable "name" {
  type        = string
  description = "Prefix name to use for the deployments."
  default     = "tomcatdatadog"
}





variable "project_id" {
  type        = string
  description = "The project to deploy resources to."
}

variable "war_filepath" {
  type        = string
  description = "Where to find the war file to deploy on the local filesystem."
}

variable "region" {
  type        = string
  description = "GCP region to deploy resources to."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone to deploy resources to. Must be a zone in the chosen region."
  default     = "us-central1-c"
}



variable "create_postgres_db" {
  type        = bool
  description = "If true, creates private PostgreSQL DB on the VPC."
  default     = false
}

variable "database_name" {
  type        = string
  description = "Name of an extra database on the db instance."
  default     = null
}

variable "database_username" {
  type        = string
  description = "Username for an extra user on the database."
  default     = null
}

variable "database_password" {
  type        = string
  sensitive   = true
  description = "Password for an extra user on the database."
  default     = null
}

variable "db_tier" {
  type        = string
  description = "Hardware tier for the DB."
  default     = "db-f1-micro"
}

