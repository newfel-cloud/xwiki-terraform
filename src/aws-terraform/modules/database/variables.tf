variable "enable_high_availability" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
}

variable "sg_map" {
  description = "security-group map"
  type        = map(any)
}