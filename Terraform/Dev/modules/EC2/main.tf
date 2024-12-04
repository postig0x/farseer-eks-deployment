#Bastion Host/App Server
#######################################

#Security Groups- AZ1
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
  ingress {
    from_port   = 2377
    to_port     = 2377
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

#Dev App Server Security Groups
#Dev-Frontend-SG
resource "aws_security_group" "frontend_sg" {
  name        = "Dev-frontend-private-subnet"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
  ingress {
    from_port   = 2377
    to_port     = 2377
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
    Name = "${var.environment}-frontend-private-sg"
  }
}

#backend-SG-AZ1
resource "aws_security_group" "backend_sg" {
  name        = "dev-backend-private-subnet-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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
    Name = "${var.environment}-backend-private-sg"
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
resource "aws_instance" "bastion" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  # user_data              = 
  depends_on = [aws_instance.frontend, aws_instance.backend]
  tags = {
    Name = "${var.environment}-bastion"
  }
}

#Frontend Private Subnet
resource "aws_instance" "frontend" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-frontend"
  }

}
resource "aws_instance" "backend" {
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_name
  # user_data              = 

  tags = {
    Name = "${var.environment}-backend"
  }

}
