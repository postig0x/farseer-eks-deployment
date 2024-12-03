# variable "prod_vpc_id" {
#   type = string
# }

# variable "availability_zones" {
#   type = list(string)
# }

# variable "dev_vpc_id" {
#   type = string
  
# }

variable "environment" {
  description = "Indicates environment (Dev,QA,Prod)"
  type        = string
}

variable "cidr_block" {
  description = "Denotes VPC CIDR Block"
  type        = string
}