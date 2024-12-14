variable "environment" {
  description = "Indicates environment (Dev,sb,Prod)"
  type        = string
}
variable "stacking" {
  description = "Indicates environment (Dev,sb,Prod)"
  type        = string
}

variable "cidr_block" {
  description = "Denotes VPC CIDR Block"
  type        = string
}