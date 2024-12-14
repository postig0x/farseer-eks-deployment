variable "environment" {
  description = "Indicates environment (Dev,QA,Prod)"
  type        = string
}

variable "cidr_block" {
  description = "Denotes VPC CIDR Block"
  type        = string
}