terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
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

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Define a Security Group with a unique name or check if it exists
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

# Data source to fetch an existing key pair from your AWS account
data "aws_key_pair" "existing_key" {
  key_name = "id_rsa.pub"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcrIO9xM572jKPvqhK/n7q95u3l9XO+PwMv88jX410UX9AV5Q7HJjQ8XQQRCJQ33NRT3DSqEROjOftyO5IEXhmI+cjQVtTLg2V9P/BXxYN+e55/ahtcsIBCr27Wsw0mzCAWVnuj+kT44auFolhQ4iSG597iKS27/GXfNX1PdsQlCmrQyvTitWPj49zktTXgkZOX8ITRi+B1gPrdzqHceHWxHJiKkw9mLdxoaSbSuQspRJmOU0unmGMQdpqqvwXc9v6U/KW4c3OEwiJPL/kkvjkjVLQ/EE+bMFgM0i5DRWNkHzD0emB6+k38cVkg4t+PkmmpKJLaxiNkSKFnRaK0msWSJO+XFqchVLwVqIAU37MynHcS3Q+swcxJ4qUkJHfoFq0Z0/DM0ccmlXZ5lzgmrYuIWxZOlUYtXGrx1rJrCrBhjOmEOHDug7BU5ZZRLQJGaFyaaX5QYvmu0Zd5/EpOuuCuK0wxeC+4Wce6vZBmDzEww1wd7tQ6GSqI2GBfWQCcms= ehisj@JERY"
}

# EC2 Instance using the key pair and security group
resource "aws_instance" "vm" {
  ami           = "ami-0917d3c16c89e5dc3"
  instance_type = "a1.medium"
  key_name      = data.aws_key_pair.existing_key.key_name

  vpc_security_group_ids = [aws_security_group.vm_sg.id]
}
