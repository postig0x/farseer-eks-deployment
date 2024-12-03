variable "dev_vpc_id" {
  type = string
}

variable "qa_private_subnet_ids"{
    type= list(string)
}

variable "qa_frontend_instance_id"{
    type = list(string)
}
