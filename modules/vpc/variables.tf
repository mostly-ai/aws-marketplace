# Global variables provisioned by Terragrunt
variable "global" { type = map(string) }
variable "global_secret" {
  type      = map(string)
  sensitive = true
}

# Module-specific variables
variable "service" {
  type    = string
  default = "vpc"
}
variable "vpc_cidr" {
  type    = string
  default = null
}
variable "enable_nat_gateway" {
  type    = bool
  default = false
}
variable "enable_vpn_gateway" {
  type    = bool
  default = false
}
variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
