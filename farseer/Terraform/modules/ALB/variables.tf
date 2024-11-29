variable "prod_vpc_id" {
  type = string
}

variable "private_subnet_ids"{
    type= list(string)
}

variable "frontend_instance_id"{
    type = list(string)
}