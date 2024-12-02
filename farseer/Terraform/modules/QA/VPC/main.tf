#VPC

resource "aws_vpc" "QA_VPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "QA_VPC"
  }
}

#Subnets - Create 2 public/private subnets per AZ
#############################################################################

#Public Subnets 
#############################################################################

resource "aws_subnet" "QA-public-subnet" {
  count = 2
  vpc_id = var.qa_vpc_id.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "qa-public-subnet-${count.index +1}"
  }
}

#IGW
resource "aws_internet_gateway" "QA_igw" {
  vpc_id = var.qa_vpc_id.id

  tags = {
    Name = "qa_igw"
  }
}

#Public Route Tables
resource "aws_route_table" "qa-public-rt" {
    count= 2
  vpc_id = var.qa_vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.QA_igw.id
  }

  tags = {
    Name = "qa_public_route_table"
  }
}

resource "aws_route_table_association" "qa-public-rt-association" {
  count          = length(aws_subnet.QA-public-subnet)
  subnet_id      = aws_subnet.QA-public-subnet[count.index].id
  route_table_id = aws_route_table.qa-public-rt.id
}
#############################################################################

#Private Subnets
#############################################################################
resource "aws_subnet" "qa-private-subnet" {
  count             = 2
  vpc_id            = var.qa_vpc_id.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "qa-private-subnet-${count.index + 1}"
  }
}

#Private Route Tables

resource "aws_route_table" "qa-private-rt" {
    count =2
  vpc_id = var.qa_vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.QA_igw.id
  }

  tags = {
    Name = "qa_private_route_table"
  }
}

resource "aws_route_table_association" "qa-private-rt-association" {
  count          = length(aws_subnet.qa-private-subnet)
  subnet_id      = aws_subnet.qa-private-subnet[count.index].id
  route_table_id = aws_route_table.qa-private-rt.id
}

#######################################################################
#Elastic IP and NAt Gateway 
##########################################################################

#Elastic IP
resource "aws_eip" "nat_eip" {
    count = 2
    domain= "vpc"

  tags = {
    Name = "qa-nat-eip"
  }
}

#Nat Gateway
resource "aws_nat_gateway" "qa_nat_gw" {
    count=2 
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.QA-public-subnet[count.index].id

  depends_on = [ aws_internet_gateway.qa_igw ]

  tags = {
    Name = "QA-Nat-Gateway"
  }
}

##############################################################################

