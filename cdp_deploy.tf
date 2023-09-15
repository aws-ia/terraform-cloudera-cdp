# Deployment and creation of CDP resources using CDP Terraform provider

# ------- CDP Credential -------
# Wait for propagation of IAM xaccount role
resource "time_sleep" "iam_propagation" {
  depends_on      = [aws_iam_role.cdp_xaccount_role]
  create_duration = "45s"
}

resource "cdp_environments_aws_credential" "cdp_cred" {
  credential_name = local.cdp_xacccount_credential_name
  role_arn        = aws_iam_role.cdp_xaccount_role.arn
  description     = "AWS Cross Account Credential for AWS env ${local.environment_name}"

  depends_on = [time_sleep.iam_propagation]
}

# ------- CDP environment -------
resource "cdp_environments_aws_environment" "cdp_env" {
  environment_name = local.environment_name
  credential_name  = cdp_environments_aws_credential.cdp_cred.credential_name
  region           = var.aws_region

  security_access = {
    default_security_group_id  = aws_security_group.cdp_default_sg.id
    security_group_id_for_knox = aws_security_group.cdp_knox_sg.id
  }

  log_storage = {
    storage_location_base        = "s3a://${local.log_storage.log_storage_bucket}${local.storage_suffix}/${local.log_storage.log_storage_object}"
    backup_storage_location_base = "s3a://${local.backup_storage.backup_storage_bucket}${local.storage_suffix}/${local.backup_storage.backup_storage_object}"
    instance_profile             = aws_iam_instance_profile.cdp_log_role_instance_profile.arn
  }

  authentication = {
    public_key_id = var.aws_key_pair
  }

  vpc_id                             = local.vpc_id
  subnet_ids                         = local.subnets_for_cdp
  endpoint_access_gateway_scheme     = local.endpoint_access_scheme
  endpoint_access_gateway_subnet_ids = local.public_subnet_ids

  freeipa = {
    instance_count_by_group = var.freeipa_instances
    multi_az                = var.multiaz
  }

  workload_analytics = var.workload_analytics
  enable_tunnel      = var.enable_ccm_tunnel
  # tags               = local.env_tags

  depends_on = [
    cdp_environments_aws_credential.cdp_cred,
    module.aws_cdp_vpc,
    aws_security_group.cdp_default_sg,
    aws_security_group_rule.cdp_default_sg_egress,
    aws_security_group_rule.cdp_default_sg_ingress,
    aws_security_group_rule.cdp_default_sg_ingress_self,
    aws_security_group.cdp_knox_sg,
    aws_security_group_rule.cdp_knox_sg_egress,
    aws_security_group_rule.cdp_knox_sg_ingress,
    aws_security_group_rule.cdp_knox_sg_ingress_self,
    random_id.bucket_suffix,
    aws_s3_bucket.cdp_storage_locations,
    # aws_s3_object.cdp_data_storage_object,
    aws_s3_object.cdp_log_storage_object,
    aws_s3_object.cdp_backup_storage_object,
    aws_s3_bucket_public_access_block.cdp_storage_locations,
    aws_iam_policy.cdp_xaccount_policy,
    data.aws_iam_policy_document.cdp_idbroker_policy_doc,
    aws_iam_policy.cdp_idbroker_policy,
    aws_iam_policy.cdp_log_data_access_policy,
    aws_iam_policy.cdp_ranger_audit_s3_data_access_policy,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach3,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach4,
    aws_iam_policy.cdp_datalake_admin_s3_data_access_policy,
    aws_iam_policy.cdp_bucket_data_access_policy,
    aws_iam_policy.cdp_datalake_restore_policy,
    aws_iam_policy.cdp_datalake_backup_policy,
    data.aws_iam_policy_document.cdp_xaccount_role_policy_doc,
    aws_iam_role.cdp_xaccount_role,
    aws_iam_role_policy_attachment.cdp_xaccount_role_attach,
    data.aws_iam_policy_document.cdp_idbroker_role_policy_doc,
    aws_iam_role.cdp_idbroker_role,
    aws_iam_instance_profile.cdp_idbroker_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_idbroker_role_attach1,
    aws_iam_role_policy_attachment.cdp_idbroker_role_attach2,
    data.aws_iam_policy_document.cdp_log_role_policy_doc,
    aws_iam_role.cdp_log_role,
    aws_iam_instance_profile.cdp_log_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_log_role_attach1,
    aws_iam_role_policy_attachment.cdp_log_role_attach2,
    aws_iam_role_policy_attachment.cdp_log_role_attach3,
    aws_iam_role.cdp_datalake_admin_role,
    data.aws_iam_policy_document.cdp_datalake_admin_role_policy_doc,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach1,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach2,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach3,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach4,
    aws_iam_instance_profile.cdp_datalake_admin_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach1,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach2,
    data.aws_iam_policy_document.cdp_ranger_audit_role_policy_doc,
    aws_iam_role.cdp_ranger_audit_role,
    aws_iam_instance_profile.cdp_ranger_audit_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach1,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach2,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach3,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach4
  ]
}

# ------- CDP admin group -------
# Create group
resource "cdp_iam_group" "cdp_admin_group" {
  group_name                    = local.cdp_admin_group_name
  sync_membership_on_user_login = false
}

# ------- CDP user group -------
# Create group
resource "cdp_iam_group" "cdp_user_group" {
  group_name                    = local.cdp_user_group_name
  sync_membership_on_user_login = false
}

# ------- IdBroker mappings -------
resource "cdp_environments_id_broker_mappings" "cdp_idbroker" {
  environment_name = cdp_environments_aws_environment.cdp_env.environment_name
  environment_crn  = cdp_environments_aws_environment.cdp_env.crn

  ranger_audit_role                   = aws_iam_role.cdp_ranger_audit_role.arn
  data_access_role                    = aws_iam_role.cdp_datalake_admin_role.arn
  ranger_cloud_access_authorizer_role = var.enable_raz ? aws_iam_role.cdp_datalake_admin_role.arn : null

  mappings = [{
    accessor_crn = cdp_iam_group.cdp_admin_group.crn
    role         = aws_iam_role.cdp_datalake_admin_role.arn
    },
    {
      accessor_crn = cdp_iam_group.cdp_user_group.crn
      role         = aws_iam_role.cdp_datalake_admin_role.arn
    }
  ]

  depends_on = [
    cdp_environments_aws_environment.cdp_env
  ]
}

# ------- CDP Datalake -------
resource "cdp_datalake_aws_datalake" "cdp_datalake" {
  datalake_name           = local.datalake_name
  environment_name        = cdp_environments_aws_environment.cdp_env.environment_name
  instance_profile        = aws_iam_instance_profile.cdp_idbroker_role_instance_profile.arn
  storage_bucket_location = "s3a://${local.data_storage.data_storage_bucket}${local.storage_suffix}/${local.data_storage.data_storage_object}"

  runtime           = var.datalake_version
  scale             = local.datalake_scale
  enable_ranger_raz = var.enable_raz
  multi_az          = var.multiaz

  # tags = local.env_tags

  depends_on = [
    cdp_environments_aws_environment.cdp_env,
    cdp_environments_id_broker_mappings.cdp_idbroker,
    cdp_environments_aws_credential.cdp_cred
  ]
}
