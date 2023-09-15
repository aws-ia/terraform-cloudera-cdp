# ------- Global settings -------
variable "infra_type" {
  type        = string
  description = "Cloud provider to deploy CDP."

  default = "aws"

  validation {
    condition     = contains(["aws"], var.infra_type)
    error_message = "Valid values for var: infra_type are (aws)."
  }
}

variable "aws_region" {
  type        = string
  description = "Region which cloud resources are created."

  default = null
}

variable "env_tags" {
  type        = map(any)
  description = "Tags applied to provised resources."

  default = null
}

variable "agent_source_tag" {
  type        = map(any)
  description = "Tag to identify deployment source."

  default = { agent_source = "tf-cdp-module" }
}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for environment. Used in resource descriptions."
}

variable "aws_key_pair" {
  type = string

  description = "Public SSH key name for CDP environment."
}

# ------- CDP environment deployment -------
variable "environment_name" {
  type        = string
  description = "CDP environment name. Defaults to '<env_prefix>-cdp-env' if not specified."

  default = null
}

variable "datalake_name" {
  type        = string
  description = "CDP Datalake name. Defaults to '<env_prefix>-aw-dl' if not specified."

  default = null
}

variable "cdp_xacccount_credential_name" {
  type        = string
  description = "CDP cross-account credential name. Defaults to '<env_prefix>-xaccount-cred' if not specified."

  default = null
}

variable "cdp_admin_group_name" {
  type        = string
  description = "CDP IAM admin group name associated with environment. Defaults to '<env_prefix>-cdp-admin-group' if not specified."

  default = null
}

variable "cdp_user_group_name" {
  type        = string
  description = "CDP IAM user group name associated with environment. Defaults to '<env_prefix>-cdp-user-group' if not specified."

  default = null
}
variable "cdp_profile" {
  type        = string
  description = "Profile for CDP credentials."

  # Profile is default unless explicitly specified
  default = "default"
}

variable "cdp_control_plane_region" {
  type        = string
  description = "CDP control plane region."

  # Region is us-west-1 unless explicitly specified
  default = "us-west-1"
}

variable "deployment_template" {
  type = string

  description = "Deployment pattern to use for cloud resources and CDP."

  validation {
    condition     = contains(["public", "semi-private", "private"], var.deployment_template)
    error_message = "Valid values for var: deployment_template are (public, semi-private, private)."
  }
}

variable "lookup_cdp_account_ids" {
  type = bool

  description = "Auto lookup CDP account and external ID using CDP CLI commands. If false, then xaccount_account_id and xaccount_external_id input variables need to be specified."

  default = true
}

variable "enable_ccm_tunnel" {
  type = bool

  description = "Flag to enable Cluster Connectivity Manager tunnel. If false, then access from cloud to CDP control plane CIDRs is required from SG ingress."

  default = true
}

variable "enable_raz" {
  type = bool

  description = "Flag to enable Ranger Authorization Service (RAZ)."

  default = true
}

variable "multiaz" {
  type = bool

  description = "Flag to specify that the FreeIPA and DataLake instances is deployed across multi-AZ."

  default = true
}

variable "freeipa_instances" {
  type = number

  description = "Number of FreeIPA instances to create in environment."

  default = 3
}

variable "workload_analytics" {
  type = bool

  description = "Flag to specify if workload analytics is enabled for CDP environment."

  default = true
}

variable "datalake_scale" {
  type = string

  description = "Scale of the Datalake. Valid values are LIGHT_DUTY, MEDIUM_DUTY_HA."

  validation {
    condition     = (var.datalake_scale == null ? true : contains(["LIGHT_DUTY", "MEDIUM_DUTY_HA"], var.datalake_scale))
    error_message = "Valid values for var: datalake_scale are (LIGHT_DUTY, MEDIUM_DUTY_HA)."
  }

  default = null
}

variable "datalake_version" {
  type = string

  description = "Datalake runtime version. Valid values are semantic versions (example, 7.2.16)."

  validation {
    condition     = (var.datalake_version == null ? true : length(regexall("\\d+\\.\\d+.\\d+", var.datalake_version)) > 0)
    error_message = "Valid values for var: datalake_version must match semantic versioning conventions."
  }

  default = "7.2.16"
}

variable "endpoint_access_scheme" {
  type = string

  description = "Workload endpoint gateway scheme. PUBLIC creates an external endpoint accessed over the internet. PRIVATE restricts traffic to be internal to VPC/Vnet. Relevant in private networks."

  validation {
    condition     = (var.endpoint_access_scheme == null ? true : contains(["PUBLIC", "PRIVATE"], var.endpoint_access_scheme))
    error_message = "Valid values for var: endpoint_access_scheme are (PUBLIC, PRIVATE)."
  }

  default = null

}

# ------- Network resources -------
variable "create_vpc" {
  type = bool

  description = "Flag if VPC should be created."

  default = true
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."

  default = "10.10.0.0/16"
}

variable "cdp_vpc_id" {
  type        = string
  description = "VPC ID for CDP environment. Required if create_vpc is false."

  default = null
}

variable "cdp_public_subnet_ids" {
  type        = list(any)
  description = "List of public subnet IDs. Required if create_vpc is false."

  default = null
}

variable "cdp_private_subnet_ids" {
  type        = list(any)
  description = "List of private subnet IDs. Required if create_vpc is false."

  default = null
}

# Security Groups
variable "security_group_default_name" {
  type = string

  description = "Default security group for CDP environment."

  default = null
}

variable "security_group_knox_name" {
  type = string

  description = "Knox security group for CDP environment."

  default = null
}

variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in security group ingress rules."

  default = {
    cidrs = [],
    ports = []
  }
}

variable "cdp_default_sg_egress_cidrs" {
  type = list(string)

  description = "Egress CIDR blocks list for CDP default security group egress rule."

  default = ["0.0.0.0/0"]
}

variable "cdp_knox_sg_egress_cidrs" {
  type = list(string)

  description = "Egress CIDR blocks list for CDP knox security group egress rule."

  default = ["0.0.0.0/0"]
}

# ------- Storage Resources -------
variable "random_id_for_bucket" {
  type = bool

  description = "Create random suffix for bucket names."

  default = true

}

variable "data_storage" {
  type = object({
    data_storage_bucket = string
    data_storage_object = string
  })

  description = "Data storage locations for CDP environment."

  default = null
}

variable "log_storage" {
  type = object({
    log_storage_bucket = string
    log_storage_object = string
  })

  description = "Optional log locations for CDP environment. If not provided follow data_storage variable."

  default = null
}

variable "backup_storage" {
  type = object({
    backup_storage_bucket = string
    backup_storage_object = string
  })

  description = "Optional backup location for CDP environment. If not provided follow data_storage variable."

  default = null
}

variable "create_kms" {

  type = bool

  description = "Flag to create AWS KMS for S3 buckets encryption."

  default = false

}

# ------- Policies -------
# Cross Account Policy (name and document)
variable "xaccount_policy_name" {
  type        = string
  description = "Cross-account policy name."

  default = null
}

variable "xaccount_account_policy_doc" {
  type        = string
  description = "Cross-acount policy document location."

  default = null
}

# CDP IDBroker Assume Role policy
variable "idbroker_policy_name" {
  type        = string
  description = "IDBroker policy name."

  default = null
}

# CDP Data Access Policies - Log
variable "log_data_access_policy_name" {
  type        = string
  description = "Log data access policy name."

  default = null
}

variable "log_data_access_policy_doc" {
  type        = string
  description = "Location or contents of log data access policy."

  default = null
}

# CDP Data Access Policies - ranger_audit_s3
variable "ranger_audit_s3_policy_name" {
  type        = string
  description = "Ranger S3 audit data access policy name."

  default = null
}

variable "ranger_audit_s3_policy_doc" {
  type        = string
  description = "Location or contents of Ranger S3 audit data access policy."

  default = null
}

# CDP Data Access Policies - datalake_admin_s3 
variable "datalake_admin_s3_policy_name" {
  type        = string
  description = "Datalake admin S3 data access policy name."

  default = null
}

variable "datalake_admin_s3_policy_doc" {
  type        = string
  description = "Location or contents of Datalake admin S3 data access policy."

  default = null
}

variable "datalake_backup_policy_doc" {
  type        = string
  description = "Datalake backup data access policy location."

  default = null
}

variable "datalake_restore_policy_doc" {
  type        = string
  description = "Datalake restore data access policy location."

  default = null
}

# CDP Data Access Policies - bucket_access
variable "bucket_access_policy_name" {
  type        = string
  description = "Bucket access data access policy name."

  default = null
}

# CDP Datalake restore Policies - datalake
variable "datalake_restore_policy_name" {
  type        = string
  description = "Datalake restore data access policy name."

  default = null
}

# CDP Datalake backup Policies - datalake
variable "datalake_backup_policy_name" {
  type        = string
  description = "Datalake backup data access policy name."

  default = null
}

variable "bucket_access_policy_doc" {
  type        = string
  description = "Bucket access data access policy."

  default = null
}

# ------- Roles -------
# Cross Account Role (name and id)
variable "xaccount_role_name" {
  type        = string
  description = "Cross-account assume role name."

  default = null
}

variable "xaccount_account_id" {
  type        = string
  description = "Cross-account account ID."

  default = null
}

variable "xaccount_external_id" {
  type        = string
  description = "Cross-account external ID."

  default = null
}

# IDBroker service role
variable "idbroker_role_name" {
  type        = string
  description = "IDBroker service role name."

  default = null
}

# Log service role
variable "log_role_name" {
  type        = string
  description = "Log service role name."

  default = null
}

# CDP Datalake Admin role
variable "datalake_admin_role_name" {
  type        = string
  description = "Datalake admin role name."

  default = null
}

# CDP Ranger Audit role
variable "ranger_audit_role_name" {
  type        = string
  description = "Ranger audit role name."

  default = null
}
