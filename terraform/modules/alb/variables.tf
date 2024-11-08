variable "lb_name" {
  type = string
}

variable "sec_grp_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "lb_tag" {
  type = string
}

variable "targetgrp_name" {
  type = string
}

variable "targetgrp_tag" {
  type = string
}


variable "ssl_policy" {
  type = string
}

variable "acm_cert_arn" {
  type = string
}

variable "http_listener_tag" {
  type = string
}

variable "https_listener_tag" {
  type = string
}

variable "vpc_id" {

}



