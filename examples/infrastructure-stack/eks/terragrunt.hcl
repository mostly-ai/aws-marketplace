terraform { source = "../../../modules/eks" }
dependency "vpc" {
  config_path  = "../vpc"
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    vpc_id               = "vpc-mockvpcid"
    private_subnet_ids   = ["subnet-mocksubnetidprivate1", "subnet-mocksubnetidprivate2"]
    public_subnet_ids    = ["subnet-mocksubnetidpublic1", "subnet-mocksubnetidpublic1"]
  }

}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  common_secret = read_terragrunt_config(find_in_parent_folders("common-secret.hcl"))
  global = local.common.locals
  global_secret = local.common_secret.locals
}

inputs = {
  global = local.global
  global_secret = local.global_secret
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
}
