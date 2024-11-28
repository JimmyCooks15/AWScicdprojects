resource "aws_vpc" "autodevs_vpc" {
  cidr_block = "172.168.0.0/16"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "autodevs_public_subnet" {
  vpc_id = aws_vpc.autodevs_vpc.id
  cidr_block = "172.168.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_internet_gateway" "autodevs_internet_gateway" {
  vpc_id = aws_vpc.autodevs_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "autodevs_public_rt" {
  vpc_id = aws_vpc.autodevs_vpc.id

  tags = {
    Name = "my-pubr"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.autodevs_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.autodevs_internet_gateway.id
}

resource "aws_route_table_association" "autodevs_route_table_assoc" {
  subnet_id = aws_subnet.autodevs_public_subnet.id
  route_table_id = aws_route_table.autodevs_public_rt.id
}

resource "aws_security_group" "autodevs_sg" {
  vpc_id = aws_vpc.autodevs_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}

resource "aws_key_pair" "autodevs_auth" {
  key_name = "id_rsa.pub"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcrIO9xM572jKPvqhK/n7q95u3l9XO+PwMv88jX410UX9AV5Q7HJjQ8XQQRCJQ33NRT3DSqEROjOftyO5IEXhmI+cjQVtTLg2V9P/BXxYN+e55/ahtcsIBCr27Wsw0mzCAWVnuj+kT44auFolhQ4iSG597iKS27/GXfNX1PdsQlCmrQyvTitWPj49zktTXgkZOX8ITRi+B1gPrdzqHceHWxHJiKkw9mLdxoaSbSuQspRJmOU0unmGMQdpqqvwXc9v6U/KW4c3OEwiJPL/kkvjkjVLQ/EE+bMFgM0i5DRWNkHzD0emB6+k38cVkg4t+PkmmpKJLaxiNkSKFnRaK0msWSJO+XFqchVLwVqIAU37MynHcS3Q+swcxJ4qUkJHfoFq0Z0/DM0ccmlXZ5lzgmrYuIWxZOlUYtXGrx1rJrCrBhjOmEOHDug7BU5ZZRLQJGaFyaaX5QYvmu0Zd5/EpOuuCuK0wxeC+4Wce6vZBmDzEww1wd7tQ6GSqI2GBfWQCcms= ehisj@JERY"
}

resource "aws_instance" "autodevs_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id
  key_name = aws_key_pair.autodevs_auth.key_name
  vpc_security_group_ids = [aws_security_group.autodevs_sg.id]
  subnet_id = aws_subnet.autodevs_public_subnet.id

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
}
