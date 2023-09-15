output "vpc_id" {
  description = "The ID of VPC."
  value       = module.cdp_vpc.vpc_id
}

output "default_route_table" {
  description = "The ID of default route table."
  value       = module.cdp_vpc.default_route_table_id
}

output "public_route_tables" {
  description = "List of IDs of public route tables."
  value       = module.cdp_vpc.public_route_table_ids
}

output "private_route_tables" {
  description = "List of IDs of private route tables."
  value       = module.cdp_vpc.private_route_table_ids
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = module.cdp_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = module.cdp_vpc.public_subnets
}