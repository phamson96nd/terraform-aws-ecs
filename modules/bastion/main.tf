provider "aws" {
  region = var.region
}

#keypair
resource "aws_key_pair" "bastion_keys" {
  for_each   = var.users
  key_name   = "bastion-${each.key}"
  public_key = file("${path.module}/keys/${each.key}.pub")
}


#ami 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

#Create bastion
resource "aws_instance" "bastion_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_keys["user1"].key_name
  tags = {
    Name = "${var.app_name}_Bastion"
  }
  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  # Userdata to install Mongo Client
  # user_data = <<-EOF
  #             #!/bin/bash
  #             sudo apt-get install gnupg curl
  #             curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  #               sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
  #               --dearmor
  #             echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  #             sudo apt-get update
  #             sudo apt-get install -y mongodb-org
  #             

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/.ssh
    echo "${file("${path.module}/keys/user2.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
  EOF
}

# Elastic IP
resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = {
    Name = "bastion-eip"
  }
}

resource "aws_eip_association" "bastion_assoc" {
  instance_id   = aws_instance.bastion_instance.id
  allocation_id = aws_eip.bastion_eip.id
}


