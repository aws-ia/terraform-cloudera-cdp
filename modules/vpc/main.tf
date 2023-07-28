module "cdp_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.env_prefix}-net"
  cidr = var.vpc_cidr

  azs = [for v in local.zones_in_region : v]
  private_subnets = (local.subnets_required.private == 0 ?
    [] :
    [
      for k, v in local.zones_in_region : cidrsubnet(var.vpc_cidr, ceil(log(local.subnets_required.total, 2)), local.subnets_required.public + k)
    ]
  )
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnets = (local.subnets_required.public == 0 ?
    [] :
    [
      for k, v in local.zones_in_region : cidrsubnet(var.vpc_cidr, ceil(log(local.subnets_required.total, 2)), k)
    ]
  )

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}
