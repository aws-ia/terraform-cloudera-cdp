# # Example of deployment and creation of CDP resources using Ansible Playbook called by TF local-exec
# # TODO: 
# # * AWS keypair

# ------- Create Configuration file for CDP Deployment via Ansible -------
resource "local_file" "cdp_deployment_template" {

  count = var.deploy_cdp == true ? 1 : 0

  content = templatefile("${path.module}/templates/cdp_config.yml.tpl", {
    # CDP environment & DL settings
    plat__env_name                  = "${var.env_prefix}-cdp-env"
    plat__datalake_name             = "${var.env_prefix}-aws-dl"
    plat__xacccount_credential_name = "${var.env_prefix}-xaccount-cred"
    plat__cdp_iam_admin_group_name  = "${var.env_prefix}-cdp-admin-group"
    plat__cdp_iam_user_group_name   = "${var.env_prefix}-cdp-user-group"
    plat__tunnel                    = (var.deployment_type == "public") ? "False" : "True"
    plat__endpoint_access_scheme    = (var.deployment_type == "semi-private") ? "PUBLIC" : "PRIVATE"
    plat__enable_raz                = "no"
    plat__env_freeipa               = "2"
    plat__workload_analytics        = "True"
    plat__tags                      = "${jsonencode(local.env_tags)}"

    # CSP settings
    plat__infra_type = "${var.infra_type}"
    plat__region     = "${var.region}"

    plat__aws_vpc_id             = "${aws_vpc.cdp_vpc.id}"
    plat__aws_public_subnet_ids  = "${jsonencode(values(aws_subnet.cdp_public_subnets)[*].id)}"
    plat__aws_private_subnet_ids = "${jsonencode(values(aws_subnet.cdp_private_subnets)[*].id)}"

    plat__aws_storage_location = "s3a://${local.data_storage.data_storage_bucket}${local.storage_suffix}"
    plat__aws_log_location     = "s3a://${local.log_storage.log_storage_bucket}${local.storage_suffix}"

    # TODO: Figure out how to best specify keypair
    plat__public_key_id                 = "${var.public_keypair}"
    plat__aws_security_group_default_id = "${aws_security_group.cdp_default_sg.id}"
    plat__aws_security_group_knox_id    = "${aws_security_group.cdp_knox_sg.id}"

    plat__aws_datalake_admin_role_arn = "${aws_iam_role.cdp_datalake_admin_role.arn}"
    plat__aws_ranger_audit_role_arn   = "${aws_iam_role.cdp_ranger_audit_role.arn}"
    plat__aws_xaccount_role_arn       = "${aws_iam_role.cdp_xaccount_role.arn}"

    plat__aws_log_instance_profile_arn      = "${aws_iam_instance_profile.cdp_log_role_instance_profile.arn}"
    plat__aws_idbroker_instance_profile_arn = "${aws_iam_instance_profile.cdp_idbroker_role_instance_profile.arn}"
    }
  )
  filename = "cdp_config.yml"
}

# ------- Create CDP Deployment -------
resource "null_resource" "cdp_deployment" {

  count = var.deploy_cdp == true ? 1 : 0

  # Setup of CDP environment using playbook_setup_cdp.yml.yml Ansible Playbook
  provisioner "local-exec" {
    command = "ansible-playbook -vvv -e '@cdp_config.yml' ${path.module}/playbook_setup_cdp.yml"
  }

  # Deletion of CDP environment using playbook_teardown_cdp.yml Ansible Playbook
  provisioner "local-exec" {
    when    = destroy
    command = "ansible-playbook -vvv -e '@cdp_config.yml' ${path.module}/playbook_teardown_cdp.yml"
  }

  # Depends on * resources to ensure CDP environment is setup/deleted after/before all pre-reqs.
  # TODO: Need to investigate further to see if this list can be trimmed.
  depends_on = [
    local_file.cdp_deployment_template,
    aws_vpc.cdp_vpc,
    aws_internet_gateway.cdp_igw,
    aws_subnet.cdp_public_subnets,
    aws_default_route_table.cdp_public_route_table,
    aws_route_table_association.cdp_public_subnets,
    aws_subnet.cdp_private_subnets,
    aws_eip.cdp_nat_gateway_eip,
    aws_nat_gateway.cdp_nat_gateway,
    aws_route_table.cdp_private_route_table,
    aws_route_table_association.cdp_private_subnets,
    aws_security_group.cdp_default_sg,
    aws_security_group.cdp_knox_sg,
    random_id.bucket_suffix,
    aws_s3_bucket.cdp_storage_locations,
    aws_s3_bucket_acl.cdp_storage_acl,
    aws_s3_object.cdp_data_storage_object,
    aws_s3_object.cdp_log_storage_object,
    aws_iam_policy.cdp_xaccount_policy,
    data.aws_iam_policy_document.cdp_idbroker_policy_doc,
    aws_iam_policy.cdp_idbroker_policy,
    aws_iam_policy.cdp_log_data_access_policy,
    aws_iam_policy.cdp_ranger_audit_s3_data_access_policy,
    aws_iam_policy.cdp_datalake_admin_s3_data_access_policy,
    aws_iam_policy.cdp_bucket_data_access_policy,
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
    data.aws_iam_policy_document.cdp_datalake_admin_role_policy_doc,
    aws_iam_role.cdp_datalake_admin_role,
    aws_iam_instance_profile.cdp_datalake_admin_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach1,
    aws_iam_role_policy_attachment.cdp_datalake_admin_role_attach2,
    data.aws_iam_policy_document.cdp_ranger_audit_role_policy_doc,
    aws_iam_role.cdp_ranger_audit_role,
    aws_iam_instance_profile.cdp_ranger_audit_role_instance_profile,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach1,
    aws_iam_role_policy_attachment.cdp_ranger_audit_role_attach2
  ]
}
