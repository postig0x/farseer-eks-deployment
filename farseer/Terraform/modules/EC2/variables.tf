#Instance Type Variable
variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "production_vpc_id" {
  type= string
}
variable "public_subnet_id" {
  type = list(string)
}

variable "private_subnet_id" {
  type = list(string)
}