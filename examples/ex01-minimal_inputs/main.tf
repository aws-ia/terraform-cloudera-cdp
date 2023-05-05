provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "ex01_minimal_inputs" {
  source = "../.."

  env_prefix = var.env_prefix
  aws_region = var.aws_region

  aws_key_pair = var.aws_key_pair

  deployment_template = var.deployment_template

  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

}
