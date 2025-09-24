output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
  
}
output "private_subnets_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
output "public_subnets_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
  
}