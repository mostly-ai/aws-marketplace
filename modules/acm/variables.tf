# Global variables provisioned by Terragrunt
variable "global" { type = map(any) }
variable "global_secret" {
  type      = map(any)
  sensitive = true
}

# Module-specific variables
variable "service" {
  type    = string
  default = "acm"
}
variable "certificate_domain_name" { type = string }
variable "create_for_wildcard" {
  type    = bool
  default = false
}
variable "hosted_zone" { type = string }
