locals {
  # ------- Global settings -------
  env_tags = merge(var.agent_source_tag, (
    coalesce(var.env_tags,
      { env_prefix = var.env_prefix }
    ))
  )

  caller_account_id = data.aws_caller_identity.current.account_id

  # ------- CDP environment deployment -------
  environment_name = coalesce(var.environment_name,
  "${var.env_prefix}-cdp-env")

  datalake_name = coalesce(var.datalake_name,
  "${var.env_prefix}-aw-dl")

  cdp_xacccount_credential_name = coalesce(var.cdp_xacccount_credential_name,
  "${var.env_prefix}-xaccount-cred")

  cdp_admin_group_name = coalesce(var.cdp_admin_group_name,
  "${var.env_prefix}-cdp-admin-group")

  cdp_user_group_name = coalesce(var.cdp_user_group_name,
  "${var.env_prefix}-cdp-user-group")

  datalake_scale = coalesce(
    var.datalake_scale,
    (var.deployment_template == "public" ?
      "LIGHT_DUTY" : "MEDIUM_DUTY_HA"
    )
  )

  endpoint_access_scheme = coalesce(
    var.endpoint_access_scheme,
    (var.deployment_template == "semi-private") ? "PUBLIC" : "PRIVATE"
  )

  # ------- Network resources -------
  vpc_id = (var.create_vpc ?
  module.aws_cdp_vpc[0].vpc_id : var.cdp_vpc_id)

  default_route_table_id  = (var.create_vpc ? module.aws_cdp_vpc[0].default_route_table : null)
  public_route_table_ids  = (var.create_vpc ? module.aws_cdp_vpc[0].public_route_tables : null)
  private_route_table_ids = (var.create_vpc ? module.aws_cdp_vpc[0].private_route_tables : null)

  public_subnet_ids = (var.create_vpc ?
  module.aws_cdp_vpc[0].public_subnets : var.cdp_public_subnet_ids)

  private_subnet_ids = (var.create_vpc ?
    module.aws_cdp_vpc[0].private_subnets : var.cdp_private_subnet_ids
  )

  subnets_for_cdp = (var.deployment_template == "public") ? (concat(local.public_subnet_ids, local.private_subnet_ids)) : (local.private_subnet_ids)

  # Security groups
  security_group_default_name = coalesce(var.security_group_default_name, "${var.env_prefix}-default-sg")

  security_group_knox_name = coalesce(var.security_group_knox_name, "${var.env_prefix}-knox-sg")

  security_group_rules_ingress = [
    {
      # CIDR ingress
      cidr     = data.aws_vpc.cdp_vpc.cidr_block_associations[*].cidr_block,
      port     = "0",
      protocol = "all"
    }
  ]

  security_group_rules_extra_ingress = [
    for idx, port in var.ingress_extra_cidrs_and_ports.ports :
    {
      cidr     = var.ingress_extra_cidrs_and_ports.cidrs
      port     = port
      protocol = "tcp"
    }
  ]

  # ------- Storage resources -------
  storage_suffix = var.random_id_for_bucket ? "-${one(random_id.bucket_suffix).hex}" : ""

  data_storage = {
    data_storage_bucket = try(var.data_storage.data_storage_bucket, "${var.env_prefix}-buk")
    data_storage_object = try(var.data_storage.data_storage_object, "data/")
  }

  log_storage = {
    log_storage_bucket = try(var.log_storage.log_storage_bucket, local.data_storage.data_storage_bucket)
    log_storage_object = try(var.log_storage.log_storage_object, "logs/")
  }

  backup_storage = {
    backup_storage_bucket = try(var.backup_storage.backup_storage_bucket, local.data_storage.data_storage_bucket)
    backup_storage_object = try(var.backup_storage.backup_storage_object, "backups/")
  }

  # ------- Policies -------
  # Cross Account Policy (name and document)
  xaccount_policy_name = coalesce(var.xaccount_policy_name, "${var.env_prefix}-xaccount-policy")

  xaccount_account_policy_doc = coalesce(var.xaccount_account_policy_doc, data.http.xaccount_account_policy_doc.response_body)

  # CDP IDBroker Assume Role Policy
  idbroker_policy_name = coalesce(var.idbroker_policy_name, "${var.env_prefix}-idbroker-policy")

  # CDP Data Access Policies - Log
  log_data_access_policy_name = coalesce(var.log_data_access_policy_name, "${var.env_prefix}-logs-policy")

  # log_data_access_policy_doc
  # ...first process placeholders in the downloaded policy doc
  log_data_access_policy_doc_processed = replace(
    replace(
      replace(
      data.http.log_data_access_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
    "$${LOGS_BUCKET}", "${local.log_storage.log_storage_bucket}${local.storage_suffix}"),
  "$${LOGS_LOCATION_BASE}", "${local.log_storage.log_storage_bucket}${local.storage_suffix}")

  # ...then assign either input or downloaded policy doc to var used in resource
  log_data_access_policy_doc = coalesce(var.log_data_access_policy_doc, local.log_data_access_policy_doc_processed)

  # CDP Data Access Policies - ranger_audit_s3
  ranger_audit_s3_policy_name = coalesce(var.ranger_audit_s3_policy_name, "${var.env_prefix}-audit-policy")

  # ranger_audit_s3_policy_doc
  # ...first process placeholders in the downloaded policy doc
  ranger_audit_s3_policy_doc_processed = replace(
    replace(
      replace(
      data.http.ranger_audit_s3_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
    "$${STORAGE_LOCATION_BASE}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}/${replace(local.data_storage.data_storage_object, "/", "")}"),
  "$${DATALAKE_BUCKET}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}")

  # ...then assign either input or downloaded policy doc to var used in resource
  ranger_audit_s3_policy_doc = coalesce(var.ranger_audit_s3_policy_doc, local.ranger_audit_s3_policy_doc_processed)

  # CDP Data Access Policies - datalake_admin_s3 
  datalake_admin_s3_policy_name = coalesce(var.datalake_admin_s3_policy_name, "${var.env_prefix}-dladmin-policy")

  # datalake_admin_s3_policy_doc
  # ...first process placeholders in the downloaded policy doc
  datalake_admin_s3_policy_doc_processed = replace(
    replace(
    data.http.datalake_admin_s3_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
  "$${STORAGE_LOCATION_BASE}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}/${replace(local.data_storage.data_storage_object, "/", "")}")

  # ...then assign either input or downloaded policy doc to var used in resource
  datalake_admin_s3_policy_doc = coalesce(var.datalake_admin_s3_policy_doc, local.datalake_admin_s3_policy_doc_processed)

  # CDP Data Access Policies - bucket_access
  bucket_access_policy_name = coalesce(var.bucket_access_policy_name, "${var.env_prefix}-storage-policy")

  # bucket_access_policy_doc
  # ...first process placeholders in the downloaded policy doc
  bucket_access_policy_doc_processed = replace(
    replace(
    data.http.bucket_access_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
  "$${DATALAKE_BUCKET}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}")

  # ...then assign either input or downloaded policy doc to var used in resource
  bucket_access_policy_doc = coalesce(var.bucket_access_policy_doc, local.bucket_access_policy_doc_processed)

  # CDP Datalake Backup Policy
  datalake_backup_policy_name = coalesce(var.datalake_backup_policy_name, "${var.env_prefix}-datalake-backup-policy")

  # datalake_backup_policy_doc
  # ...first process placeholders in the downloaded policy doc
  datalake_backup_policy_doc_processed = replace(
    replace(
    data.http.datalake_backup_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
  "$${BACKUP_LOCATION_BASE}", "${local.backup_storage.backup_storage_bucket}${local.storage_suffix}")

  # ...then assign either input or downloaded policy doc to var used in resource
  datalake_backup_policy_doc = coalesce(var.datalake_backup_policy_doc, local.datalake_backup_policy_doc_processed)

  # CDP Datalake Restore Policy
  datalake_restore_policy_name = coalesce(var.datalake_restore_policy_name, "${var.env_prefix}-datalake-restore-policy")

  # datalake_restore_policy_doc
  # ...first process placeholders in the downloaded policy doc
  datalake_restore_policy_doc_processed = replace(
    replace(
    data.http.datalake_restore_policy_doc.response_body, "$${ARN_PARTITION}", "aws"),
  "$${BACKUP_LOCATION_BASE}", "${local.backup_storage.backup_storage_bucket}${local.storage_suffix}")

  # ...then assign either input or downloaded policy doc to var used in resource
  datalake_restore_policy_doc = coalesce(var.datalake_restore_policy_doc, local.datalake_restore_policy_doc_processed)

  # ------- Roles -------
  xaccount_role_name = coalesce(var.xaccount_role_name, "${var.env_prefix}-xaccount-role")

  xaccount_account_id = coalesce(var.xaccount_account_id, var.lookup_cdp_account_ids ? data.cdp_environments_aws_credential_prerequisites.cdp_prereqs.account_id : null)

  xaccount_external_id = coalesce(var.xaccount_external_id, var.lookup_cdp_account_ids ? data.cdp_environments_aws_credential_prerequisites.cdp_prereqs.external_id : null)

  idbroker_role_name = coalesce(var.idbroker_role_name, "${var.env_prefix}-idbroker-role")

  log_role_name = coalesce(var.log_role_name, "${var.env_prefix}-logs-role")

  datalake_admin_role_name = coalesce(var.datalake_admin_role_name, "${var.env_prefix}-dladmin-role")

  ranger_audit_role_name = coalesce(var.ranger_audit_role_name, "${var.env_prefix}-audit-role")

}
