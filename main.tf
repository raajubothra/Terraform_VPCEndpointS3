provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
  
}

resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}"

  }
}


resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.public_subnet1_cidr}"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "${var.public_subnet1_name}"
    }
}

resource "aws_subnet" "subnet1-private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.private_subnet1_cidr}"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "${var.private_subnet1_name}"
    }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.IGW_name}"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

    tags = {
    Name = "${var.PublicRouteTable}"
  }
}


resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = "${aws_vpc.vpc.id}"

 

    tags = {
    Name = "${var.PrivateRouteTable}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet1-public.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}





resource "aws_eip" "lb" {
  vpc      = true
}





resource "aws_security_group" "allow_tls" {
  name        = "MySecuirtyGroup"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description      = "Allow Ssh"
    from_port        = 22   
    to_port          = 22
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}



resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "com.amazonaws.ap-south-1.s3"
  
}
# associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "route_table_association" {
  route_table_id  = "${aws_route_table.PrivateRouteTable.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}