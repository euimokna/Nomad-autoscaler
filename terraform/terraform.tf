terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.env
      Project     = var.pjt
      COST_CENTER = "${var.env}_${var.pjt}"
    }
  }
}