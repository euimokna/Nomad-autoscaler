locals {
  sg_tcp_ports = [22, 8200, 8500, 8502, 8300, 8301, 8302, 8600, 4646, 4647]
  sg_udp_ports = [8301, 8302, 8600]
}

resource "aws_security_group" "ucmp" {
  vpc_id = aws_vpc.ucmp.id
  name   = "${var.env}_${var.pjt}-sg"

  dynamic "ingress" {
    for_each = local.sg_tcp_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = local.sg_udp_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
