data "aws_availability_zones" "main" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.global.environment}-${var.service}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.main.names, 0, 3)
  public_subnets  = [for k, v in slice(data.aws_availability_zones.main.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.main.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k + 3)]

  enable_nat_gateway      = var.enable_nat_gateway
  enable_vpn_gateway      = var.enable_vpn_gateway
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_dns_hostnames    = true

  default_security_group_egress = [
    {
      description = "Allow All Outbound Traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  default_security_group_ingress = [
    {
      description = "Allow all internal TCP and UDP"
      self        = true
    }
  ]

  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/vpc",
    "Name" : "${var.global.environment}-${var.service}"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1,
    "type"                   = "public"
    "Name"                   = "${var.global.environment}-${var.service}-public",
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1,
    "type"                            = "private",
    "Name"                            = "${var.global.environment}-${var.service}-private",
  }

}
