# Find Availability Zones is AWS Region
data "aws_availability_zones" "zones_in_region" {
  state = "available"
}
