#VPC

resource "aws_vpc" "production_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Production_VPC"
  }
}

#Subnets - Create 2 public/private subnets per AZ
#############################################################################

#Public Subnets 
#############################################################################

resource "aws_subnet" "prod-public-subnet" {
  count = 2
  vpc_id = var.prod_vpc_id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index +1}"
  }
}

#IGW
resource "aws_internet_gateway" "production_igw" {
  vpc_id = var.prod_vpc_id

  tags = {
    Name = "production_igw"
  }
}

#Public Route Tables
resource "aws_route_table" "public-rt" {
    count= 2
  vpc_id = var.prod_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  count          = length(aws_subnet.prod-public-subnet)
  subnet_id      = aws_subnet.prod-public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}
#############################################################################

#Private Subnets
#############################################################################
resource "aws_subnet" "prod-private-subnet" {
  count             = 2
  vpc_id            = var.prod_vpc_id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

#Private Route Tables

resource "aws_route_table" "private-rt" {
    count =2
  vpc_id = var.prod_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(aws_subnet.prod-private-subnet)
  subnet_id      = aws_subnet.prod-private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

#######################################################################
#Elastic IP and NAt Gateway 
##########################################################################

#Elastic IP
resource "aws_eip" "nat_eip" {
    count = 2
    domain= "vpc"

  tags = {
    Name = "nat-eip"
  }
}

#Nat Gateway
resource "aws_nat_gateway" "nat_gw_AZ1" {
    count=2 
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.prod-public-subnet[count.index].id

  depends_on = [ aws_internet_gateway.production_igw ]

  tags = {
    Name = "Nat Gateway-AZ1"
  }
}

##############################################################################

#VPC Peering

data "aws_vpc" "default" {
    default = true
}

data "aws_route_table" "default" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_peering_connection" "prod-dev-peering" {
  peer_vpc_id = var.prod_vpc_id
  vpc_id      = data.aws_vpc.default.id
  auto_accept = true
}

