variable "environment" {
  description = "Indicates environment (Dev,sb,Prod)"
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
variable "public_subnet_id1" {}
variable "public_subnet_id2" {}
variable "private_subnet_id1" {}
variable "private_subnet_id2" {}
variable "private_subnet_id3" {}
variable "private_subnet_id4" {}
variable "key_name" {
  type = string
}