# Find the AWS account details
data "aws_caller_identity" "current" {}

# Find details of the AWS VPC
data "aws_vpc" "cdp_vpc" {
  id = local.vpc_id
}

# HTTP get request to download policy documents
# ..Cross Account Policy
data "http" "xaccount_account_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-common/src/main/resources/definitions/aws-cb-policy.json"
}

# ..CDP Log Data Access Policies
data "http" "log_data_access_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-common/src/main/resources/definitions/cdp/aws-cdp-log-policy.json"
}

# ..CDP ranger_audit_s3 Data Access Policies
data "http" "ranger_audit_s3_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-common/src/main/resources/definitions/cdp/aws-cdp-ranger-audit-s3-policy.json"
}

# ..CDP datalake_admin_s3 Data Access Policies
data "http" "datalake_admin_s3_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-common/src/main/resources/definitions/cdp/aws-cdp-datalake-admin-s3-policy.json"
}

# ..CDP bucket_access Data Access Policies
data "http" "bucket_access_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-common/src/main/resources/definitions/cdp/aws-cdp-bucket-access-policy.json"
}

# ..CDP Data Lake Backup Policies
data "http" "datalake_backup_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-cloudformation/src/main/resources/definitions/aws-datalake-backup-policy.json"
}

# ..CDP Data Lake Restore Policies
data "http" "datalake_restore_policy_doc" {
  url = "https://raw.githubusercontent.com/hortonworks/cloudbreak/CB-2.73.0/cloud-aws-cloudformation/src/main/resources/definitions/aws-datalake-restore-policy.json"
}

# Lookup the CDP control plane account and external IDs
data "cdp_environments_aws_credential_prerequisites" "cdp_prereqs" {}
