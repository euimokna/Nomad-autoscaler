resource "aws_vpc" "ucmp" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.env}-${var.pjt}-vpc"
    Service = "vpc"
  }
}

data "aws_availability_zones" "available" {}

// resource "aws_subnet" "bastion" {
//   vpc_id                  = aws_vpc.ucmp.id
//   cidr_block              = var.bastion_cidr
//   availability_zone       = "ap-northeast-2a"
//   map_public_ip_on_launch = true
//   tags = {
//     Name    = "sbn-${var.env}-${var.pjt}-puba",
//     Service = "puba"
//   }
// }

resource "aws_subnet" "main_1" {
  vpc_id                  = aws_vpc.ucmp.id
  cidr_block              = var.main_1_cidr
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "sbn-${var.env}-${var.pjt}-pria",
    Service = "pria"
  }
}

resource "aws_subnet" "main_2" {
  vpc_id                  = aws_vpc.ucmp.id
  cidr_block              = var.main_2_cidr
  availability_zone       = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name    = "sbn-${var.env}-${var.pjt}-prib",
    Service = "prib"
  }
}