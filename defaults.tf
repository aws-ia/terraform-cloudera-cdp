locals {
  # ------- Global settings -------
  env_tags = coalesce(var.env_tags, {
    env_prefix = var.env_prefix
    comment    = "Created with Terraform"
  })

  caller_account_id = data.aws_caller_identity.current.account_id
  # ------- Network Resources -------
  vpc_name = coalesce(var.vpc_name, "${var.env_prefix}-net")

  igw_name = coalesce(var.igw_name, "${var.env_prefix}-igw")

  # Calculate number of subnets based on the deployment_type
  subnets_required = {
    total   = (var.deployment_type == "public") ? length(data.aws_availability_zones.zones_in_region.names) : 2 * length(data.aws_availability_zones.zones_in_region.names)
    public  = length(data.aws_availability_zones.zones_in_region.names)
    private = (var.deployment_type == "public") ? 0 : length(data.aws_availability_zones.zones_in_region.names)
  }

  # Public Network infrastructure
  # if not specified via TF var then calculate. 1 per AZ and conditional on local.subnets_required.public
  public_subnets = coalesce(var.public_subnets,
    local.subnets_required.public == 0 ?
    [] :
    [
      for idx, az in data.aws_availability_zones.zones_in_region.names :
      {
        name = "${var.env_prefix}-sbnt-pub-${format("%02d", idx + 1)}"
        az   = az
        cidr = cidrsubnet(var.vpc_cidr, ceil(log(local.subnets_required.total, 2)), idx)
        tags = {
          "kubernetes.io/role/elb" = "1",
          "Name"                   = "${var.env_prefix}-sbnt-pub-${format("%02d", idx + 1)}"
        }
      }
  ])

  public_route_table_name = coalesce(var.public_route_table_name, "${var.env_prefix}-public-rtb")

  # Private Network infrastructure
  # if not specified via TF var then calculate. 1 per AZ and conditional on local.subnets_required.private
  private_subnets = coalesce(var.private_subnets,
    local.subnets_required.private == 0 ?
    [] :
    [
      for idx, az in data.aws_availability_zones.zones_in_region.names :
      {
        name = "${var.env_prefix}-sbnt-pvt-${format("%02d", idx + 1)}"
        az   = az
        cidr = cidrsubnet(var.vpc_cidr, ceil(log(local.subnets_required.total, 2)), local.subnets_required.public + idx)
        tags = {
          "kubernetes.io/role/internal-elb" = "1",
          "Name"                            = "${var.env_prefix}-sbnt-pvt-${format("%02d", idx + 1)}"
        }
      }
  ])

  private_route_table_name = coalesce(var.private_route_table_name, "${var.env_prefix}-private-rtb")

  nat_gateway_name = coalesce(var.nat_gateway_name, "${var.env_prefix}-ngw")

  # Security Groups
  security_group_default_name = coalesce(var.security_group_default_name, "${var.env_prefix}-default-sg")

  security_group_knox_name = coalesce(var.security_group_knox_name, "${var.env_prefix}-knox-sg")

  security_group_rules_ingress = [
    {
      # CIDR ingress
      cidr     = [var.vpc_cidr],
      port     = "0",
      protocol = "all"
    },
    # Access to CDP control plane
    {
      cidr     = var.cdp_control_plane_cidrs,
      port     = "9443",
      protocol = "tcp"
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

  # ------- Storage Resources -------
  storage_suffix = var.random_id_for_bucket ? "-${one(random_id.bucket_suffix).hex}" : ""

  data_storage = {
    data_storage_bucket  = try(var.data_storage.data_storage_bucket, "${var.env_prefix}-buk")
    data_storage_objects = try(var.data_storage.data_storage_objects, ["ranger/audit/"])
  }

  log_storage = {
    log_storage_bucket  = try(var.log_storage.log_storage_bucket, local.data_storage.data_storage_bucket)
    log_storage_objects = try(var.log_storage.log_storage_objects, ["logs/"])
  }

  # ------- Policies -------
  # Cross Account Policy (name and document)
  xaccount_policy_name = coalesce(var.xaccount_policy_name, "${var.env_prefix}-xaccount-policy")

  xaccount_account_policy_doc = coalesce(var.xaccount_account_policy_doc, data.http.xaccount_account_policy_doc.response_body)

  # CDP IDBroker Assume Role policy
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
    "$${STORAGE_LOCATION_BASE}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}"),
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
  "$${STORAGE_LOCATION_BASE}", "${local.data_storage.data_storage_bucket}${local.storage_suffix}")

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

  # ------- Roles -------
  xaccount_role_name = coalesce(var.xaccount_role_name, "${var.env_prefix}-xaccount-role")

  xaccount_account_id = coalesce(var.xaccount_account_id, var.lookup_cdp_account_ids ? data.external.cdpcli[0].result.account_id : null)

  xaccount_external_id = coalesce(var.xaccount_external_id, var.lookup_cdp_account_ids ? data.external.cdpcli[0].result.external_id : null)

  idbroker_role_name = coalesce(var.idbroker_role_name, "${var.env_prefix}-idbroker-role")

  log_role_name = coalesce(var.log_role_name, "${var.env_prefix}-logs-role")

  datalake_admin_role_name = coalesce(var.datalake_admin_role_name, "${var.env_prefix}-dladmin-role")

  ranger_audit_role_name = coalesce(var.ranger_audit_role_name, "${var.env_prefix}-audit-role")

}
