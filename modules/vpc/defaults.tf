locals {
  # ------- Determine subnet details from inputs -------
  subnets_required = {
    total   = (var.deployment_template == "public") ? length(data.aws_availability_zones.zones_in_region.names) : 2 * length(data.aws_availability_zones.zones_in_region.names)
    public  = length(data.aws_availability_zones.zones_in_region.names)
    private = (var.deployment_template == "public") ? 0 : length(data.aws_availability_zones.zones_in_region.names)
  }
}