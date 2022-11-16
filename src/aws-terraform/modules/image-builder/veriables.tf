variable "region" {
  default = "The region is used to naming style. ex: us-east-2"
  type    = string
}

variable "base_img_id" {
  description = "Ubuntu, 20.04 LTS; ex: us-east-2 = ami-0d5bf08bc8017c83b"
  type        = string
}