data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    # Matches the latest AL2023 release
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "web" {
 ami           = data.aws_ami.al2023.id
 instance_type = var.instance_type
 subnet_id     = aws_subnet.public.id
 vpc_security_group_ids = [aws_security_group.ssh.id]
 key_name = aws_key_pair.generated.key_name


 associate_public_ip_address = true

 tags = {
   Name        = "${var.environment}-server"
   Environment = var.environment
 }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${var.environment}-key.pem"
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.environment}-terraform-key"
  public_key = tls_private_key.example.public_key_openssh
}