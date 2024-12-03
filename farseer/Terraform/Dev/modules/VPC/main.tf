##################################################
### VPC ###
##################################################

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.environment}_VPC"
  }
}
#######################################################################
#Gateways 
#######################################################################

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}_igw"
  }
}

#Elastic IP
resource "aws_eip" "nat_eip" {

    domain= "vpc"

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

#Nat Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet.id

  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = "${var.environment}-natgw"
  }
}

##############################################################################
#Subnets - Create public/private subnets per AZ
#############################################################################

#Public Subnets 
#############################################################################

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
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
    Name = "${var.environment}_public_route_table"
  }
}

resource "aws_route_table_association" "pub-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
#############################################################################

#Private Subnets
#############################################################################
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

#Private Route Tables

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  route {
    cidr_block                = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name = "${var.environment}_private_route_table"
  }
}

resource "aws_route_table_association" "private-rt-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}


##################################################
### VPC PEERING ###
##################################################
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = data.aws_vpc.default.id
  auto_accept   = true
  tags = {
    Name = "${var.environment}_vpc_peering"
  }
}

##################################################
### DEFAULT VPC ###
##################################################
# Setting Default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to access the default route table of the default VPC
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Add a route for VPC peering to the default route table
resource "aws_route" "vpc_peering_route" {
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.vpc.cidr_block  # Adjust based on peer VPC
  vpc_peering_connection_id  = aws_vpc_peering_connection.peering.id
}