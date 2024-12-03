terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
module "VPC"{
source = "./modules/VPC"
prod_vpc_id = module.EC2.availability_zones
availability_zones = ["us-east-1a", "us-east-1b" ]
}

module "EC2" {
source= "./modules/EC2"
public_subnet_id = module.VPC.public_id
private_subnet_id = module.VPC.public_subnet_id
instance_type = "t3.micro"
production_vpc_id = module.VPC.production_vpc_id
}


module ALB{
    source= "./modules/ALB"
    private_subnet_ids = module.VPC.private_subnet_ids
    frontend_instance_id = module.EC2.farseer_frontend_instance_id
    prod_vpc_id = module.VPC.production_vpc_id
}