variable "environment" {
  description = "Indicates environment (Dev,QA,Prod)"
  type        = string
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "ec2_ami" {
  description = "AMI ID"
  type        = string
}

variable "vpc_id" {}

variable "public_subnet_id" {}

variable "private_subnet_id" {}

variable "key_name" {
  type = string
}