provider "aws" {
  profile = var.profile
  region  = var.region
}

module "ex03_cdp_pre_reqs_example" {
  source = "../.."

  profile = var.profile
  region  = var.region

  env_prefix = var.env_prefix

  # TODO: Figure out how to best specify keypair
  public_keypair = var.public_keypair

  deploy_cdp             = var.deploy_cdp
  deployment_type        = var.deployment_type
  lookup_cdp_account_ids = var.lookup_cdp_account_ids

  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

  random_id_for_bucket = var.random_id_for_bucket
}
