#VPC

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "dev_VPC"
  }
}

#Subnets - Create 2 public/private subnets per AZ
#############################################################################

#Public Subnets 
#############################################################################

resource "aws_subnet" "dev-public-subnet" {
  vpc_id = var.dev_vpc_id.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet"
  }
}

#IGW
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = var.dev_vpc_id.id

  tags = {
    Name = "dev_igw"
  }
}

#Public Route Tables
resource "aws_route_table" "dev-public-rt" {
  
  vpc_id = var.dev_vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev_public_route_table"
  }
}

resource "aws_route_table_association" "dev-pub-rt-association" {
  subnet_id      = aws_subnet.dev-public-subnet.id
  route_table_id = aws_route_table.dev-public-rt.id
}
#############################################################################

#Private Subnets
#############################################################################
resource "aws_subnet" "dev-private-subnet" {
  vpc_id            = var.dev_vpc_id.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-private-subnet"
  }
}

#Private Route Tables

resource "aws_route_table" "dev-private-rt" {
  vpc_id = var.dev_vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev_public_route_table"
  }
}

resource "aws_route_table_association" "dev-private-rt-association" {
  subnet_id      = aws_subnet.dev-private-subnet.id
  route_table_id = aws_route_table.dev-private-rt.id
}

#######################################################################
#Elastic IP and NAt Gateway 
##########################################################################

#Elastic IP
resource "aws_eip" "nat_eip" {

    domain= "vpc"

  tags = {
    Name = "dev-nat-eip"
  }
}

#Nat Gateway
resource "aws_nat_gateway" "dev_nat_gw" {
    count=2 
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.dev-public-subnet.id

  depends_on = [ aws_internet_gateway.dev_igw ]

  tags = {
    Name = "Dev Nat Gateway"
  }
}

##############################################################################

