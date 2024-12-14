##################################################
### VPC ###
##################################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}-${var.stacking}_VPC"
  }
}
#######################################################################
#Gateways 
#######################################################################

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-${var.stacking}_igw"
  }
}

#Elastic IP
resource "aws_eip" "nat_eip1" {

  domain = "vpc"

  tags = {
    Name = "${var.environment}-${var.stacking}-nat-eip1"
  }
}

resource "aws_eip" "nat_eip2" {

  domain = "vpc"

  tags = {
    Name = "${var.environment}-${var.stacking}-nat-eip2"
  }
}

#Nat Gateway
resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public-subnet1.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-${var.stacking}-natgw1"
  }
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public-subnet2.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-${var.stacking}-natgw2"
  }
}

##############################################################################
#Subnets - Create public/private subnets per AZ
#############################################################################

#Public Subnets 
#############################################################################

resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                             = "${var.environment}-${var.stacking}-public-subnet1"
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/cluster/dev-${var.stacking}" = "owned"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                             = "${var.environment}-${var.stacking}-public-subnet2"
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/cluster/dev-${var.stacking}" = "owned"
  }
}



#Public Route Tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }


  tags = {
    Name = "${var.environment}-${var.stacking}_public_route_table"
  }
}

resource "aws_route_table_association" "pub-rt-association1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "pub-rt-association2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}
#############################################################################

#Private Subnets
#############################################################################
resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name                              = "${var.environment}-${var.stacking}-private-subnet1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/dev-${var.stacking}"  = "owned"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name                              = "${var.environment}-${var.stacking}-private-subnet2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/dev-${var.stacking}"  = "owned"
  }
}

resource "aws_subnet" "private-subnet3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name                              = "${var.environment}-${var.stacking}-private-subnet3"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/dev-${var.stacking}"  = "owned"
  }
}

resource "aws_subnet" "private-subnet4" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name                              = "${var.environment}-${var.stacking}-private-subnet4"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/dev-${var.stacking}"  = "owned"
  }
}
#Private Route Tables

resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw1.id
  }
  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name = "${var.environment}-${var.stacking}_private_route_table"
  }
}

resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw2.id
  }
  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name = "${var.environment}-${var.stacking}_private_route_table"
  }
}

resource "aws_route_table_association" "private-rt-association1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt1.id
}

resource "aws_route_table_association" "private-rt-association2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt2.id
}

resource "aws_route_table_association" "private-rt-association3" {
  subnet_id      = aws_subnet.private-subnet3.id
  route_table_id = aws_route_table.private-rt1.id
}

resource "aws_route_table_association" "private-rt-association4" {
  subnet_id      = aws_subnet.private-subnet4.id
  route_table_id = aws_route_table.private-rt2.id
}

# ##################################################
# ### VPC PEERING ###
# ##################################################

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.vpc.id
  vpc_id      = data.aws_vpc.default.id
  auto_accept = true
  tags = {
    Name = "${var.environment}-${var.stacking}_vpc_peering"
  }
}

##################################################
### DEFAULT VPC ###
##################################################
# Setting Default VPC
data "aws_vpc" "default" {
  default = true
}

