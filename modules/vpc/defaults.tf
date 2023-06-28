locals {

  azs_to_exclude = ["us-east-1e"] # List of AWS AZs which are not supported by CDP

  # Create a list of supported zones in the region
  zones_in_region = tolist(setsubtract(data.aws_availability_zones.zones_in_region.names, local.azs_to_exclude))

  # ------- Determine subnet details from inputs -------
  subnets_required = {
    total   = (var.deployment_template == "public") ? length(local.zones_in_region) : 2 * length(local.zones_in_region)
    public  = length(local.zones_in_region)
    private = (var.deployment_template == "public") ? 0 : length(local.zones_in_region)
  }
}