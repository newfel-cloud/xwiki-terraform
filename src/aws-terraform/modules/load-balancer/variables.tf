variable "region" {
  default = "The region is used to naming style. ex: us-east-2"
  type    = string
}

variable "vpc" {
  description = "the AWS VPC in the current AWS Region."
  type        = any
}

variable "subnets" {
  description = " default subnets in the current region."
  type        = any
}

variable "sg_map" {
  description = "security-group map"
  type        = map(any)
}

variable "ec2_1" {
  description = "Main ec2 instance1, it will be used to target-group."
  type        = any
}

variable "ec2_2" {
  description = "Main ec2 instance2, it will be used to target-group."
  type        = any
}

variable "template" {
  description = "Provides an EC2 launch template resource. Can be used to create instances or auto scaling groups."
  type        = any
}