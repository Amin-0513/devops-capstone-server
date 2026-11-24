variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "saa-key"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "server_port" {
  type    = number
  default = 5000
}

variable "grafana_port" {
  type    = number
  default = 3020
}
