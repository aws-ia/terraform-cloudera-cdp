variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"

}

variable "tags" {
  type        = map(any)
  description = "Tags applied to provised resources"

}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for the environment. Used in resource descriptions"
}

variable "deployment_template" {
  type = string

  description = "Deployment Pattern to use for Cloud resources and CDP"

  validation {
    condition     = contains(["public", "semi-private", "private"], var.deployment_template)
    error_message = "Valid values for var: deployment_template are (public, semi-private, private)."
  }
}
