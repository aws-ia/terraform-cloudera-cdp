# CDP environment & DL settings
output "env_name" {
  value = "${var.env_prefix}-cdp-env"

  description = "CDP environment name"
}

output "datalake_name" {
  value = "${var.env_prefix}-aws-dl"

  description = "CDP Datalake name"
}

output "xacccount_credential_name" {
  value = "${var.env_prefix}-xaccount-cred"

  description = "Cross Account credential name"
}


output "cdp_iam_admin_group_name" {
  value = "${var.env_prefix}-cdp-admin-group"

  description = "CDP IAM admin group name"
}

output "cdp_iam_user_group_name" {
  value = "${var.env_prefix}-cdp-user-group"

  description = "CDP IAM user group name"
}

output "tunnel" {
  value = (var.deployment_type == "public") ? "False" : "True"

  description = "Flag to enable SSH tunnelling for the environment"
}

output "endpoint_access_scheme" {
  value = (var.deployment_type == "semi-private") ? "PUBLIC" : "PRIVATE"

  description = "The scheme for the workload endpoint gateway. `PUBLIC` creates an external endpoint that can be accessed over the Internet. `PRIVATE` restricts the traffic to be internal to the VPC / Vnet. Relevant in Private Networks."
}

output "enable_raz" {
  value = "no"

  description = "Flag to enable Ranger Authorization Service (RAZ)"
}

output "env_freeipa" {
  value = "2"

  description = "Number of instances for the FreeIPA service of the environment"
}

output "workload_analytics" {
  value = "True"

  description = "Flag to enable Workload Analytics"
}

output "tags" {
  value = local.env_tags

  description = "Tags associated with the environment and its resources"
}

# CSP settings
output "infra_type" {
  value = "aws"

  description = "Cloud Service Provider type"
}

output "region" {
  value = var.region

  description = "Cloud provider region of the Environment"

}

output "aws_vpc_id" {
  value = aws_vpc.cdp_vpc.id

  description = "AWS VPC ID"
}

output "aws_public_subnet_ids" {
  value = values(aws_subnet.cdp_public_subnets)[*].id

  description = "AWS public subnet IDs"
}

output "aws_private_subnet_ids" {
  value = values(aws_subnet.cdp_private_subnets)[*].id

  description = "AWS private subnet IDs"
}

output "aws_storage_location" {
  value = "s3a://${local.data_storage.data_storage_bucket}${local.storage_suffix}"

  description = "AWS data storage location"
}

output "aws_log_location" {
  value = "s3a://${local.log_storage.log_storage_bucket}${local.storage_suffix}"

  description = "AWS log storage location"
}

# TODO: Figure out how to best specify keypair
output "public_key_id" {
  value = var.public_keypair

  description = "Keypair name in Cloud Service Provider"
}

output "aws_security_group_default_id" {
  value = aws_security_group.cdp_default_sg.id

  description = "AWS security group id for default CDP SG"
}

output "aws_security_group_knox_id" {
  value = aws_security_group.cdp_knox_sg.id

  description = "AWS security group id for Knox CDP SG"
}

output "aws_datalake_admin_role_arn" {
  value = "aws_iam_role.cdp_datalake_admin_role.arn"

  description = "Datalake Admin role ARN"
}

output "aws_ranger_audit_role_arn" {
  value = aws_iam_role.cdp_ranger_audit_role.arn

  description = "Ranger Audit role ARN"
}

output "aws_xaccount_role_arn" {
  value = aws_iam_role.cdp_xaccount_role.arn

  description = "Cross Account role ARN"
}

output "aws_log_instance_profile_arn" {
  value = aws_iam_instance_profile.cdp_log_role_instance_profile.arn

  description = "Log instance profile ARN"
}

output "aws_idbroker_instance_profile_arn" {
  value = aws_iam_instance_profile.cdp_idbroker_role_instance_profile.arn

  description = "IDBroker instance profile ARN"
}
