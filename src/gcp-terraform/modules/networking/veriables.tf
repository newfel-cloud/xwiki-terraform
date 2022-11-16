variable "project_id" {
  description = "The project ID will be created the address in. ex: datadogtest-367504"
  type        = string
}

variable "region" {
  description = "The region will be created the address in, ex: asia-east1, us-west1"
  type        = string
}

variable "internal_addresses" {
  description = "A list of interal ip addresses will be created, The IP addresses must be \"inside\" the specified subnetwork. Every name will be asigned address by index automatically."
  type        = list(string)
}