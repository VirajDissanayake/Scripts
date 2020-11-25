#round 2
provider "aws" {
  region = "us-east-1"
}

#create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  
  tags = {
    Name = "prod-vpc"
  }
}
#IGW
resource "aws_internet_gateway" "igw" {
  depends_on = [
    aws_vpc.prod-vpc
  ]
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "igw"
  }
}
#EIP for NAT gateway
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.RT-IG-Association
  ]
  vpc = true
}
#NAT gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "gw NAT"
  }
}
#Route table igw
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "internet route"
  }
}
#Route table Nat
resource "aws_route_table" "route-table-nat" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "internet route"
  }
}
#public subnet
resource "aws_subnet" "public-subnet" {
  depends_on = [
    aws_vpc.prod-vpc
  ]
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-sub"
  }
}
#private subnet
resource "aws_subnet" "private-subnet" {
  depends_on = [
    aws_vpc.prod-vpc
  ]
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-sub"
  }
}
#route table association public subnet
resource "aws_route_table_association" "RT-IG-Association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-table.id
}
#route table association private subnet
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.route-table-nat.id
}
#security group
resource "aws_security_group" "allow_web-traffic" {
  name        = "allow_web-traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
#create ec2
resource "aws_instance" "web-server" {
  ami           = "ami-0947d2ba12ee1ff75" 
  instance_type = "t2.micro"

  tags = {
    Name = "web-server"
  }
  availability_zone = "us-east-1a"
  key_pair = "main-key"
}