output "public_id" {
  value = aws_subnet.public[*].id
}

output "private_id" {
  value = aws_subnet.private[*].id
}

output "qa_vpc_id" {
  value= aws_vpc.qa_vpc.id
  
}

output "qa_private_subnet_ids" {
  value = aws_subnet.qa-private-subnet[*].id
}
output "availability_zones"{
  value= aws_availability_zones
}