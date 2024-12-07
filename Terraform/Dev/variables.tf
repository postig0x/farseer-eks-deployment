variable "region" {
  default = "us-east-1"
}

variable "environment" {
  description = "Indicates environment (Dev,QA,Prod)"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
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
  default = "dev-ssh-key"
}

# variable "dev_key" {
#   sensitive = true
# }

variable "XAI_KEY" {
  type = string
  sensitive = true
}

variable "DOCKER_CREDS_USR" {
  type = string
}

variable "DOCKER_CREDS_PSW" {
  type = string
  sensitive = true
}
