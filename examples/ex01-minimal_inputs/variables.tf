# ------- Global settings -------
variable "aws_profile" {
  type        = string
  description = "Profile for AWS cloud credentials."

  # Profile is default unless explicitly specified
  default = "default"
}

variable "aws_region" {
  type        = string
  description = "Region in which cloud resources will be created."
}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for environment. Used in resource descriptions."
}

variable "aws_key_pair" {
  type = string

  description = "Name of public SSH key for CDP environment."

}

# ------- CDP Environment Deployment -------
variable "deployment_template" {
  type = string

  description = "Deployment pattern to use for cloud resources and CDP."
}

# ------- Network Resources -------
variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in Security Group Ingress rules."
}
