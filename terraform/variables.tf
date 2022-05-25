#####################
# default tag
#####################
variable "env" {
  default = "dev"
}

variable "pjt" {
  default = "ucmp"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "key_name" {
  default = "ucmp-key"
}

variable "client_count" {
  default = 0
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

// variable "bastion_cidr" {
//   default = "10.0.10.0/24"
// }

variable "main_1_cidr" {
  default = "172.31.20.0/24"
}

variable "main_2_cidr" {
  default = "172.31.40.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

#####################
# autoscaler
#####################
variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 5
}

variable "desired_capacity" {
  default = 1
}