resource "aws_internet_gateway" "ucmp" {
  vpc_id = aws_vpc.ucmp.id
  tags = {
    Name    = "igw-${var.env}-${var.pjt}-internetgw",
    Service = "internetgw"
  }
}

resource "aws_eip" "ucmp" {
  vpc = true
  tags = {
    Name    = "eip-${var.env}-${var.pjt}-nat-puba"
    Service = "nat-puba"
  }
}

resource "aws_nat_gateway" "ucmp" {
  allocation_id = aws_eip.ucmp.id
  subnet_id     = aws_subnet.main_1.id
  tags = {
  Name    = "nat-${var.env}-${var.pjt}-puba",
  Service = "puba"
  }
}

resource "aws_default_route_table" "ucmp" {
  default_route_table_id = aws_vpc.ucmp.default_route_table_id
  tags = {
    Name    = "rt-${var.env}-${var.pjt}-default",
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ucmp.id
  }
}

resource "aws_default_network_acl" "ucmp" {
  default_network_acl_id = aws_vpc.ucmp.default_network_acl_id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.ucmp.id
  tags = {
    Name    = "rt-${var.env}-${var.pjt}-nat",
    Service = "nat-route-table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.ucmp.id // 모든 IP가 NAT로 가도록 설정
    //gateway_id = aws_internet_gateway.ucmp.id // 임시로 설정
  }
}

// resource "aws_route_table_association" "ucmp" {
//   subnet_id      = aws_subnet.bastion.id
//   route_table_id = aws_default_route_table.ucmp.id
// }

resource "aws_route_table_association" "asso_sbn_pria" {
  subnet_id      = aws_subnet.main_1.id
  //route_table_id = aws_route_table.route_nat.id   //bastion을 쓰는경우 
  route_table_id = aws_default_route_table.ucmp.id 
}

resource "aws_route_table_association" "asso_sbn_prib" {
  subnet_id      = aws_subnet.main_2.id
  route_table_id = aws_route_table.route_nat.id
}
