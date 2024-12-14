#Bastion Host/App Server
#######################################

#Security Groups
#Bastion Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
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
    Name = "${var.environment}-bastion-sg"
  }
}

####################################################

#Prod App Server Security Groups
#Prod-Frontend-SG
resource "aws_security_group" "frontend_sg1" {
  name        = "prod-frontend-private-subnet1"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.2.0.0/24"]
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
    Name = "${var.environment}-frontend-private-sg1"
  }
}

resource "aws_security_group" "frontend_sg2" {
  name        = "prod-frontend-private-subnet2"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.2.1.0/24"]
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
    Name = "${var.environment}-frontend-private-sg2"
  }
}

#backend-SG-AZ1
resource "aws_security_group" "backend_sg1" {
  name        = "prod-backend-private-subnet-sg1"
  description = "Security group for backend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.2.0.0/24"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.2.2.0/24"]
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
    Name = "${var.environment}-backend-private-sg1"
  }
}

resource "aws_security_group" "backend_sg2" {
  name        = "prod-backend-private-subnet-sg2"
  description = "Security group for backend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.2.1.0/24"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.2.3.0/24"]
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
    Name = "${var.environment}-backend-private-sg2"
  }
}

##################################################
### SSH KEY ###
##################################################
# Read the public key from the specified path
# //NOT USING THIS FOR NOW BUT LEAVING JUST IN CASE
# locals {
#   public_key = file(var.public_key_path)
# }

# Generate a new SSH key pair
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.generated_key.public_key_openssh
# public_key = local.public_key  # Path to your public key file //LEAVING THIS IN CASE
}

# Saving private key as local tmp file on Jenkins server.
resource "local_file" "save_private_key" {
  content  = tls_private_key.generated_key.private_key_pem
  filename = "/tmp/${var.key_name}.pem" # Temp file
}

###############################################################
#EC2
##############################################################

#EC2
#Bastion Host 
resource "aws_instance" "bastion1" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id1
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-bastion1"
  }
}

resource "aws_instance" "bastion2" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id2
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-bastion2"
  }
}

#Frontend Private Subnet
resource "aws_instance" "frontend1" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id1
  vpc_security_group_ids = [aws_security_group.frontend_sg1.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-frontend1"
  }
}

resource "aws_instance" "frontend2" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id2
  vpc_security_group_ids = [aws_security_group.frontend_sg2.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-frontend2"
  }
}

resource "aws_instance" "backend1" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id3
  vpc_security_group_ids = [aws_security_group.backend_sg1.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-backend1"
  }
}

resource "aws_instance" "backend2" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id4
  vpc_security_group_ids = [aws_security_group.backend_sg2.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-backend2"
  }
}