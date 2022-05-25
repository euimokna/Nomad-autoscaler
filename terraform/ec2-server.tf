## EC2 server 
data "template_file" "server" {
  template = file("./template/al2_server.tpl")
}

data "aws_ami" "server" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "server" {
  subnet_id                   = aws_subnet.main_1.id
  ami                         = data.aws_ami.server.image_id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [
    aws_security_group.ucmp.id
  ]
  iam_instance_profile = aws_iam_instance_profile.nomad_server.name
  user_data = data.template_file.server.rendered

  tags = {
    type = "server"
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}