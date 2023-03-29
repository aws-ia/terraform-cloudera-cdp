output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.cdp_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.cdp_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.cdp_vpc.public_subnets
}