variable "region" {
  default = "us-east-1"
}

variable "environment" {
  description = "Indicates environment (Dev,sb,Prod)"
  type        = string
  default     = "sb"
}

variable "cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "key_name" {
  type    = string
  default = "sb-ssh-key"
}
# variable "DOCKER_CREDS_USR"{}
# variable "DOCKER_CREDS_PSW" {}
# variable "XAI_KEY" {}