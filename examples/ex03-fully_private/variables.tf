# ------- Global settings -------
variable "profile" {
  type        = string
  description = "Profile for AWS cloud credentials"

  # Profile is default unless explicitly specified
  default = "default"
}

variable "region" {
  type        = string
  description = "Region which Cloud resources will be created"
}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for the environment. Used in resource descriptions"
}

variable "public_keypair" {
  type = string

  description = "Name of the Public SSH key for the CDP environment"

}

# ------- CDP Environment Deployment -------
variable "deployment_type" {
  type = string

}
variable "deploy_cdp" {
  type = bool

  description = "Deploy the CDP environment as part of Terraform"

}

variable "lookup_cdp_account_ids" {
  type = bool

  description = "Auto lookup CDP Acount and External ID using CDP CLI commands"

}

# ------- Network Resources -------
variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in Security Group Ingress rules"
}

# ------- Storage Resources -------
variable "random_id_for_bucket" {
  type = bool

}
