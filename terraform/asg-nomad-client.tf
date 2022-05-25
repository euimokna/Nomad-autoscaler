data "template_file" "nomad_client" {
  template = file("./template/al2_client.tpl")
    vars = {
    server_ip       = aws_instance.server.private_ip
  }
}

## client media용 AMI이미지  
data "aws_ami" "nomad_client" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_autoscaling_group" "nomad_client" {
  name                = "nomad_client_autoscaler"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  #load_balancers      = local.load_balancers #checking........
  vpc_zone_identifier = [aws_subnet.main_1.id, aws_subnet.main_2.id]

  launch_template {
    id      = aws_launch_template.nomad_client.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "nomad_client" {
  name                   = "nomad_client_autoscaler"
  image_id               = data.aws_ami.nomad_client.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [
    aws_security_group.ucmp.id
  ]
  user_data              = base64encode(data.template_file.nomad_client.rendered)

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_client.name
  }
}  