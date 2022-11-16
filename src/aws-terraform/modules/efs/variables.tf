variable "subnet" {
  description = "The subnet to add the mount target in."
  type        = any
}

variable "sg_map" {
  description = "security-group map"
  type        = map(any)
}