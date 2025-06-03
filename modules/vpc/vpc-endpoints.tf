module "vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.8"

  vpc_id                     = module.vpc.vpc_id
  security_group_ids         = [module.vpc.default_security_group_id]
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      tags            = { Name = "${var.global.environment}-s3-vpc-gateway" }
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    },
  }

  tags = {
    "ConfigLocation" : "mostly-ai/aws-marketplace/configuration/${var.service}"
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/vpc",
    "Name" : "${var.global.environment}-${var.service}"
  }
}
