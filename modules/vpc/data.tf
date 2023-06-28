# Find Availability Zones is AWS region
data "aws_availability_zones" "zones_in_region" {
  state = "available"
}
