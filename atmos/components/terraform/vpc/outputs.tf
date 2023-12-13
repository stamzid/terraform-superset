output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.subnets.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.subnets.public_subnet_ids
}

output "private_cidr_blocks" {
  description = "List of private subnet cidrs"
  value       = module.subnets.private_subnet_cidrs
}

output "athena_sg_id" {
  description = "ID of the athena security group"
  value       = aws_security_group.athena_sg.id
}

output "vpc_cidr_block" {
  description = "CIDR block of vpc"
  value       = module.vpc.vpc_cidr_block
}

output "ecs_sg_id" {
  description = "ID of the ecs security group"
  value       = aws_security_group.ecs_sg.id
}

output "alb_sg_id" {
  description = "ID of the alb security group"
  value       = aws_security_group.alb_sg.id
}
