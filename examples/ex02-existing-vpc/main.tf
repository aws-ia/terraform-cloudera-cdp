provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "ex02_existing_vpc" {
  source = "../.."

  env_prefix = var.env_prefix
  aws_region = var.aws_region

  aws_profile  = var.aws_profile
  aws_key_pair = var.aws_key_pair

  deployment_template = var.deployment_template

  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

  create_vpc             = var.create_vpc
  cdp_vpc_id             = aws_vpc.cdp_vpc.id
  cdp_public_subnet_ids  = values(aws_subnet.cdp_public_subnets)[*].id
  cdp_private_subnet_ids = values(aws_subnet.cdp_private_subnets)[*].id

  # Explicit dependency on resources in vpc.tf
  depends_on = [
    aws_internet_gateway.cdp_igw,
    aws_default_route_table.cdp_public_route_table,
    aws_nat_gateway.cdp_nat_gateway,
    aws_route_table.cdp_private_route_table
  ]

}
