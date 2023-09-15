# CDP environment & DL settings
output "cdp_env_name" {
  value = local.environment_name

  description = "CDP environment name."
}

output "cdp_datalake_name" {
  value = "${var.env_prefix}-aws-dl"

  description = "CDP Datalake name."
}

output "cdp_xacccount_credential_name" {
  value = "${var.env_prefix}-xaccount-cred"

  description = "Cross-Account credential name."
}


output "cdp_iam_admin_group_name" {
  value = "${var.env_prefix}-cdp-admin-group"

  description = "CDP IAM admin group name."
}

output "cdp_iam_user_group_name" {
  value = "${var.env_prefix}-cdp-user-group"

  description = "CDP IAM user group name."
}

output "cdp_tunnel_enabled" {
  value = (var.deployment_template == "public") ? "false" : "true"

  description = "Flag to enable SSH tunneling for CDP environment."
}

output "cdp_endpoint_access_scheme" {
  value = (var.deployment_template == "semi-private") ? "PUBLIC" : "PRIVATE"

  description = "Workload endpoint gateway scheme. `PUBLIC` creates an external endpoint accessed over the internet. `PRIVATE` restricts traffic to be internal to VPC/Vnet. Relevant in private networks."
}

output "cdp_enable_raz" {
  value = var.enable_raz

  description = "Flag to enable Ranger Authorization Service (RAZ) for CDP environment."
}

output "cdp_enable_multiaz" {
  value = var.multiaz

  description = "Flag to specify if multi-AZ deployment is enabled for CDP environment."
}

output "cdp_freeipa_instances" {
  value = var.freeipa_instances

  description = "Number of instances for environment FreeIPA service."
}

output "cdp_workload_analytics" {
  value = var.workload_analytics

  description = "Flag to enable workload analytics."
}

output "tags" {
  value = local.env_tags

  description = "Tags associated with environment and its resources."
}

# CDP settings
output "cdp_profile" {
  value = var.cdp_profile

  description = "Profile for CDP credentials."
}

output "cdp_control_plane_region" {
  value = var.cdp_control_plane_region

  description = "CDP control plane region."
}

# CSP settings
output "infra_type" {
  value = var.infra_type

  description = "Cloud service provider type."
}

output "aws_region" {
  value = var.aws_region

  description = "Cloud provider environment region."

}

output "aws_vpc_id" {
  value = local.vpc_id

  description = "AWS VPC ID."
}

output "aws_default_route_table_id" {
  value = local.default_route_table_id

  description = "AWS default route table ID."
}

output "aws_public_route_table_ids" {
  value = local.public_route_table_ids

  description = "AWS public route table IDs."
}

output "aws_private_route_table_ids" {
  value = local.private_route_table_ids

  description = "AWS private route table IDs."
}

output "aws_public_subnet_ids" {
  value = local.public_subnet_ids

  description = "AWS public subnet IDs."
}

output "aws_private_subnet_ids" {
  value = local.private_subnet_ids

  description = "AWS private subnet IDs."
}

output "aws_storage_location" {
  value = "s3a://${local.data_storage.data_storage_bucket}${local.storage_suffix}/${local.data_storage.data_storage_object}"

  description = "AWS data storage location."
}

output "aws_log_location" {
  value = "s3a://${local.log_storage.log_storage_bucket}${local.storage_suffix}/${local.log_storage.log_storage_object}"

  description = "AWS log storage location."
}

output "aws_backup_location" {
  value = "s3a://${local.backup_storage.backup_storage_bucket}${local.storage_suffix}/${local.backup_storage.backup_storage_object}"

  description = "AWS backup storage location."
}

output "public_key_id" {
  value = var.aws_key_pair

  description = "Keypair name in cloud service provider."
}

output "aws_security_group_default_id" {
  value = aws_security_group.cdp_default_sg.id

  description = "AWS security group ID for default CDP SG."
}

output "aws_security_group_knox_id" {
  value = aws_security_group.cdp_knox_sg.id

  description = "AWS security group ID for Knox CDP SG."
}

output "aws_datalake_admin_role_arn" {
  value = aws_iam_role.cdp_datalake_admin_role.arn

  description = "Datalake admin role ARN."
}

output "aws_ranger_audit_role_arn" {
  value = aws_iam_role.cdp_ranger_audit_role.arn

  description = "Ranger audit role ARN."
}

output "aws_xaccount_role_arn" {
  value = aws_iam_role.cdp_xaccount_role.arn

  description = "Cross-Account role ARN."
}

output "aws_log_instance_profile_arn" {
  value = aws_iam_instance_profile.cdp_log_role_instance_profile.arn

  description = "Log instance profile ARN."
}

output "aws_idbroker_instance_profile_arn" {
  value = aws_iam_instance_profile.cdp_idbroker_role_instance_profile.arn

  description = "IDBroker instance profile ARN."
}
