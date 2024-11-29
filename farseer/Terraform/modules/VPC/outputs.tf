output "public_id" {
  value = aws_subnet.public[*].id
}

output "private_id" {
  value = aws_subnet.private[*].id
}

output "production_vpc_id" {
  value= aws_vpc.production_vpc.id
  
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "availability_zones"{
  value= aws_availability_zones
}