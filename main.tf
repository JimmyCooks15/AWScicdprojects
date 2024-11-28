terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "vm_sg" {
  name        = "vm_security_group_${timestamp()}"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_key_pair" "existing_key" {
  key_name = "id_rsa"
}

resource "aws_instance" "vm" {
  ami                         = "ami-0917d3c16c89e5dc3"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids      = [aws_security_group.vm_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "TfmVM"
  }
}

output "vm_ip" {
  value = aws_instance.vm.public_ip
}
