output "vpc_id" {
  value= aws_vpc.vpc.id
}

output "public_subnet_id1" {
  value = aws_subnet.public-subnet1.id
}

output "public_subnet_id2" {
  value = aws_subnet.public-subnet2.id
}

output "private_subnet_id1" {
  value = aws_subnet.private-subnet1.id
}

output "private_subnet_id2" {
  value = aws_subnet.private-subnet2.id
}

output "private_subnet_id3" {
  value = aws_subnet.private-subnet3.id
}

output "private_subnet_id4" {
  value = aws_subnet.private-subnet4.id
}