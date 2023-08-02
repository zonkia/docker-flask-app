provider "aws" {
  region = var.region
}


data "aws_ami" "amazon-linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "mstan-terra-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "mstan-terra-vpc"
  }
}

resource "tls_private_key" "terra-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terra-key-pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.terra-private-key.public_key_openssh
}

resource "local_file" "terra-ssh-key" {
  filename = "${aws_key_pair.terra-key-pair.key_name}.pem"
  content = tls_private_key.terra-private-key.private_key_pem
}

#subnety--------------------------------
resource "aws_subnet" "mstan-terra-public-subnet1" {
  vpc_id                  = aws_vpc.mstan-terra-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "mstan-terra-public-subnet1"
  }
}

resource "aws_subnet" "mstan-terra-public-subnet2" {
  vpc_id                  = aws_vpc.mstan-terra-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "mstan-terra-public-subnet2"
  }
}

#internet gateway--------------------------------
resource "aws_internet_gateway" "mstan-terra-igw" {
  vpc_id = aws_vpc.mstan-terra-vpc.id

  tags = {
    Name = "mstan-terra-igw"
  }
}
#route tables--------------------------------
resource "aws_route_table" "mstan-terra-public-rt" {
  vpc_id = aws_vpc.mstan-terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mstan-terra-igw.id
  }

  tags = {
    Name = "mstan-terra-public-rt"
  }
}

#przypisanie subnetów do route table--------------------------------
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mstan-terra-public-subnet1.id
  route_table_id = aws_route_table.mstan-terra-public-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.mstan-terra-public-subnet2.id
  route_table_id = aws_route_table.mstan-terra-public-rt.id
}

#security groups--------------------------------



resource "aws_security_group" "mstan-terra-front-sg" {
  name   = "mstan-terra-front-sg"
  vpc_id = aws_vpc.mstan-terra-vpc.id
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#  ingress {
#    from_port   = var.ssh_port
#    to_port     = var.ssh_port
#    protocol    = "tcp"
#    cidr_blocks = [var.my_ip]
#  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# instancja public
resource "aws_instance" "mstan-terra-app-instance" {
  ami               = data.aws_ami.amazon-linux2.id
  instance_type     = var.instance_size
  user_data         = templatefile("data.sh", {
    port            = var.app_port
    image_name      = var.image_name
  })
  key_name          = var.key_pair_name
  tags              = { Name = "mstan-terra-app-instance" }
  subnet_id         = aws_subnet.mstan-terra-public-subnet2.id
  security_groups   = ["${aws_security_group.mstan-terra-front-sg.id}"]
  source_dest_check = false
}   
