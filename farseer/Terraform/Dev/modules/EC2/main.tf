#Bastion Host/App Server
#######################################

#Security Groups- AZ1
#Bastion Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.dev_vpc_id.id

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
    Name = "dev-bastion-sg"
  }
}

####################################################

#Dev App Server Security Groups
#Dev-Frontend-SG
resource "aws_security_group" "dev_frontend_sg" {
  name        = "Dev-frontend-private-subnet"
  description = "Security group for frontend servers"
  vpc_id      = var.dev_vpc_id.id

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
    Name = "dev-frontend-private-sg"
  }
}

#backend-SG-AZ1
resource "aws_security_group" "dev_backend_sg" {
  name        = "dev-backend-private-subnet-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.dev_vpc_id.id

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
    Name = "dev-backend-private-sg"
  }
}

###############################################################
#EC2
##############################################################

#EC2
#Bastion Host 
resource "aws_instance" "dev-bastion" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "dev-bastion-host"
  }
}

#Frontend Private Subnet
resource "aws_instance" "farseer-frontend" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id.id
  vpc_security_group_ids = [aws_security_group.dev_frontend_sg]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "dev-frontend"
  }

}
resource "aws_instance" "farseer-backend" {
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id.id
  vpc_security_group_ids = [aws_security_group.dev_backend_sg]
  key_name               = "bastionHost-keypair"

  tags = {
    Name = "dev-backend"
  }

}
