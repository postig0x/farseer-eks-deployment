#Bastion Host/App Server
#######################################

#Security Groups- AZ1
#Bastion Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for frontend servers"
  vpc_id      = aws_vpc.Production_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "bastion-sg-az1"
  }
}

####################################################

#App Server Security Groups- AZ1
#Frontend-SG-AZ1
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-private-subnet-sg-az1"
  description = "Security group for frontend servers"
  vpc_id      = var.production_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
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
    Name = "frontend-private-sg-az1"
  }
}

#backend-SG-AZ1
resource "aws_security_group" "backend_sg" {
  name        = "backend-private-subnet-sg-az1"
  description = "Security group for frontend servers"
  vpc_id      = var.production_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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
    Name = "backend-private-sg-az1"
  }
}

###############################################################
#EC2
##############################################################

#EC2
#Bastion Host 
resource "aws_instance" "farseer-bastion" {
  count                  = 2
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "farseer_bastion_az${count.index + 1}"
  }
}

#Frontend Private Subnet
resource "aws_instance" "farseer-frontend" {
  count                  = 2
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.frontend_sg]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "farseer_frontend_az${count.index + 1}"
  }

}
resource "aws_instance" "farseer-backend" {
  count                  = 2
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.backend_sg]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "farseer_backend_az${count.index + 1}"
  }

}
