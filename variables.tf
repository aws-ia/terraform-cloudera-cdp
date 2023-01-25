# ------- Global settings -------
variable "profile" {
  type        = string
  description = "Profile for AWS cloud credentials"

  # Profile is default unless explicitly specified
  default = "default"
}

variable "infra_type" {
  type        = string
  description = "Cloud Provider to deploy CDP."

  default = "aws"

  validation {
    condition     = contains(["aws"], var.infra_type)
    error_message = "Valid values for var: infra_type are (aws)."
  }
}

variable "region" {
  type        = string
  description = "Region which Cloud resources will be created"

  default = null
}

variable "env_tags" {
  type        = map(any)
  description = "Tags applied to provised resources"

  default = null
}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for the environment. Used in resource descriptions"
}

# TODO: Figure out how to best specify keypair
variable "public_keypair" {
  type = string

  description = "Name of the Public SSH key for the CDP environment"

}

# ------- CDP Environment Deployment -------
variable "deployment_type" {
  type = string

  description = "Deployment Pattern to use for Cloud resources and CDP"

  validation {
    condition     = contains(["public", "semi-private", "fully-private"], var.deployment_type)
    error_message = "Valid values for var: deployment_type are (public, semi-private, fully-private)."
  }
}
variable "deploy_cdp" {
  type = bool

  description = "Deploy the CDP environment as part of Terraform"

  default = false
}

variable "lookup_cdp_account_ids" {
  type = bool

  description = "Auto lookup CDP Acount and External ID using CDP CLI commands"

  default = false
}

# ------- Network Resources -------
variable "vpc_name" {
  type        = string
  description = "VPC name"

  default = null
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"

  default = "10.10.0.0/16"
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway"

  default = null
}

# Public Network infrastructure
variable "public_subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
    tags = map(string)
  }))

  description = "List of Public Subnets"
  default     = null
}

variable "public_route_table_name" {
  type        = string
  description = "Public Route Table Name"

  default = null
}

# Private Network infrastructure
variable "private_subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
    tags = map(string)
  }))

  description = "List of Private Subnets"
  default     = null
}

variable "private_route_table_name" {
  type = string

  description = "Private Route Table"
  default     = null
}

variable "nat_gateway_name" {
  type = string

  description = "Nat Gateway"
  default     = null
}

# Security Groups
variable "security_group_default_name" {
  type = string

  description = "Default Security Group for CDP environment"

  default = null
}

variable "security_group_knox_name" {
  type = string

  description = "Knox Security Group for CDP environment"

  default = null
}

variable "cdp_control_plane_cidrs" {
  type = list(string)

  description = "CIDR for access to CDP Control Plane"

  default = ["52.36.110.208/32", "52.40.165.49/32", "35.166.86.177/32"]
}

variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in Security Group Ingress rules"

  default = {
    cidrs = [],
    ports = []
  }
}

# ------- Storage Resources -------
variable "random_id_for_bucket" {
  type = bool

  description = "Create a random suffix for the bucket names"

  default = false

}

variable "data_storage" {
  type = object({
    data_storage_bucket  = string
    data_storage_objects = list(string)
  })

  description = "Storage locations for CDP environment"

  default = null
}

variable "log_storage" {
  type = object({
    log_storage_bucket  = string
    log_storage_objects = list(string)
  })

  description = "Optional log locations for CDP environment. If not provided follow the data_storage variable"

  default = null
}

# ------- Policies -------
# Cross Account Policy (name and document)
variable "xaccount_policy_name" {
  type        = string
  description = "Cross Account Policy name"

  default = null
}

variable "xaccount_account_policy_doc" {
  type        = string
  description = "Location of cross acount policy document"

  default = null
}

# CDP IDBroker Assume Role policy
variable "idbroker_policy_name" {
  type        = string
  description = "IDBroker Policy name"

  default = null
}

# CDP Data Access Policies - Log
variable "log_data_access_policy_name" {
  type        = string
  description = "Log Data Access Policy Name"

  default = null
}

variable "log_data_access_policy_doc" {
  type        = string
  description = "Location or Contents of Log Data Access Policy"

  default = null
}

# CDP Data Access Policies - ranger_audit_s3
variable "ranger_audit_s3_policy_name" {
  type        = string
  description = "Ranger S3 Audit Data Access Policy Name"

  default = null
}

variable "ranger_audit_s3_policy_doc" {
  type        = string
  description = "Location or Contents of Ranger S3 Audit Data Access Policy"

  default = null
}

# CDP Data Access Policies - datalake_admin_s3 
variable "datalake_admin_s3_policy_name" {
  type        = string
  description = "Datalake Admin S3 Data Access Policy Name"

  default = null
}

variable "datalake_admin_s3_policy_doc" {
  type        = string
  description = "Location or Contents of Datalake Admin S3 Data Access Policy"

  default = null
}

# CDP Data Access Policies - bucket_access
variable "bucket_access_policy_name" {
  type        = string
  description = "Bucket Access Data Access Policy Name"

  default = null
}

variable "bucket_access_policy_doc" {
  type        = string
  description = "Bucket Access Data Access Policy"

  default = null
}

# ------- Roles -------
# Cross Account Role (name and id)
variable "xaccount_role_name" {
  type        = string
  description = "Cross account Assume role Name"

  default = null
}

variable "xaccount_account_id" {
  type        = string
  description = "Account ID of the cross account"

  default = null
}

variable "xaccount_external_id" {
  type        = string
  description = "External ID of the cross account"

  default = null
}

# IDBroker service role
variable "idbroker_role_name" {
  type        = string
  description = "IDBroker service role Name"

  default = null
}

# Log service role
variable "log_role_name" {
  type        = string
  description = "Log service role Name"

  default = null
}

# CDP Datalake Admin role
variable "datalake_admin_role_name" {
  type        = string
  description = "Datalake Admin role Name"

  default = null
}

# CDP Ranger Audit role
variable "ranger_audit_role_name" {
  type        = string
  description = "Ranger Audit role Name"

  default = null
}
