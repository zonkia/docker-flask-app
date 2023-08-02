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

resource "aws_vpc" "terra-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "terra-vpc"
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
resource "aws_subnet" "terra-public-subnet1" {
  vpc_id                  = aws_vpc.terra-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "terra-public-subnet1"
  }
}

resource "aws_subnet" "terra-public-subnet2" {
  vpc_id                  = aws_vpc.terra-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "terra-public-subnet2"
  }
}

#internet gateway--------------------------------
resource "aws_internet_gateway" "terra-igw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "terra-igw"
  }
}
#route tables--------------------------------
resource "aws_route_table" "terra-public-rt" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra-igw.id
  }

  tags = {
    Name = "terra-public-rt"
  }
}

#przypisanie subnetów do route table--------------------------------
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.terra-public-subnet1.id
  route_table_id = aws_route_table.terra-public-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.terra-public-subnet2.id
  route_table_id = aws_route_table.terra-public-rt.id
}

#security groups--------------------------------



resource "aws_security_group" "terra-front-sg" {
  name   = "terra-front-sg"
  vpc_id = aws_vpc.terra-vpc.id
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "terra-app-instance-policy" {
  name        = "ECR-Pull-Policy"
  path        = "/"
  description = "Policy for pulling image from private registry"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role" "terra-app-instance-role" {
  name = "Docker-Application-Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "terra-app-instance-policy-attatchment" {
  name       = "DockerAppInstancePolicyAttatchment"
  roles      = [aws_iam_role.terra-app-instance-role.name]
  policy_arn = aws_iam_policy.terra-app-instance-policy.arn
}

resource "aws_iam_instance_profile" "terra-app-instance-profile" {
  name = "DockerAppInstanceProfile"
  role = aws_iam_role.terra-app-instance-role.name
}


# instancja public
resource "aws_instance" "terra-app-instance" {
  ami               = data.aws_ami.amazon-linux2.id
  instance_type     = var.instance_size
  user_data         = templatefile("data.sh", {
    port            = var.app_port
    image_name      = var.image_name
    region          = var.region
    ecr_registry    = var.ecr_registry
  })
  key_name          = var.key_pair_name
  tags              = { Name = "terra-app-instance" }
  subnet_id         = aws_subnet.terra-public-subnet2.id
  security_groups   = ["${aws_security_group.terra-front-sg.id}"]
  source_dest_check = false
  iam_instance_profile = aws_iam_instance_profile.terra-app-instance-profile.name
}   
