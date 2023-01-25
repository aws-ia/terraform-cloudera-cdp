provider "aws" {
  profile = var.profile
  region  = var.region
}

# ------- Read Policy Documents into local_file data resource -------
data "local_file" "log_data_access_policy_doc" {
  filename = var.log_data_access_policy_doc_location
}

data "local_file" "ranger_audit_s3_policy_doc" {
  filename = var.ranger_audit_s3_policy_doc_location
}

data "local_file" "datalake_admin_s3_policy_doc" {
  filename = var.datalake_admin_s3_policy_doc_location
}

data "local_file" "bucket_access_policy_doc" {
  filename = var.bucket_access_policy_doc_location
}

# ------- Call CDP module -------
module "ex04_cdp_pre_reqs_example" {
  source = "../.."

  profile = var.profile
  region  = var.region

  env_prefix = var.env_prefix

  # TODO: Figure out how to best specify keypair
  public_keypair = var.public_keypair

  env_tags = var.env_tags

  deploy_cdp      = var.deploy_cdp
  deployment_type = var.deployment_type

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  igw_name                = var.igw_name
  public_subnets          = var.public_subnets
  public_route_table_name = var.public_route_table_name

  private_subnets          = var.private_subnets
  private_route_table_name = var.private_route_table_name
  nat_gateway_name         = var.nat_gateway_name

  security_group_default_name   = var.security_group_default_name
  security_group_knox_name      = var.security_group_knox_name
  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

  random_id_for_bucket = var.random_id_for_bucket
  data_storage         = var.data_storage
  log_storage          = var.log_storage

  xaccount_policy_name        = var.xaccount_policy_name
  xaccount_account_policy_doc = var.xaccount_account_policy_doc

  idbroker_policy_name = var.idbroker_policy_name

  log_data_access_policy_name = var.log_data_access_policy_name
  log_data_access_policy_doc  = data.local_file.log_data_access_policy_doc.content

  ranger_audit_s3_policy_name = var.ranger_audit_s3_policy_name
  ranger_audit_s3_policy_doc  = data.local_file.ranger_audit_s3_policy_doc.content

  datalake_admin_s3_policy_name = var.datalake_admin_s3_policy_name
  datalake_admin_s3_policy_doc  = data.local_file.datalake_admin_s3_policy_doc.content

  bucket_access_policy_name = var.bucket_access_policy_name
  bucket_access_policy_doc  = data.local_file.bucket_access_policy_doc.content

  xaccount_role_name   = var.xaccount_role_name
  xaccount_account_id  = var.xaccount_account_id
  xaccount_external_id = var.xaccount_external_id

  idbroker_role_name       = var.idbroker_role_name
  log_role_name            = var.log_role_name
  datalake_admin_role_name = var.datalake_admin_role_name
  ranger_audit_role_name   = var.ranger_audit_role_name
}
