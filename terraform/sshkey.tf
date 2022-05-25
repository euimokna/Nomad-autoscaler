# ssh 접속 키를 생성
resource "tls_private_key" "ca_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > ./ec2-${var.env}-${var.pjt}.pem"

  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.pjt}-${var.env}-${var.key_name}"
  public_key = tls_private_key.ca_key.public_key_openssh
}


output "private_key" {
  value = nonsensitive(tls_private_key.ca_key.private_key_pem)
}