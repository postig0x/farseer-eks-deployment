# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use.
# Instead, use environment variables or IAM roles to manage credentials securely.
# Indicating Provider for Terraform to use
provider "aws" {
  #  access_key = var.aws_access_key        # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  #  secret_key = var.aws_secret_key        # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region = var.region # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

module "VPC" {
  source      = "./modules/VPC"
  environment = var.environment
  cidr_block  = var.cidr_block
}

module "EC2" {
  source            = "./modules/EC2"
  environment       = var.environment
  vpc_id            = module.VPC.vpc_id
  ec2_ami           = var.ec2_ami
  public_subnet_id  = module.VPC.public_subnet_id
  private_subnet_id = module.VPC.private_subnet_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  # dev_key = var.dev_key
  xai_key = var.XAI_KEY
  docker_usr = var.DOCKER_CREDS_USR
  docker_psw = var.DOCKER_CREDS_PSW
}