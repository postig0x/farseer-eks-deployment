variable "qa_vpc_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "qa-private-subnets" {
  type=list(string)
}