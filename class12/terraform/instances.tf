resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux (example)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = aws_key_pair.generated.key_name


  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Student-Instance"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "terraform-key.pem"
}

resource "aws_key_pair" "generated" {
  key_name   = "terraform-key"
  public_key = tls_private_key.example.public_key_openssh
}