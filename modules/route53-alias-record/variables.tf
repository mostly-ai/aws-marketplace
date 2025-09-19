# Global variables provisioned by Terragrunt
variable "global" { type = map(any) }
variable "global_secret" {
  type      = map(any)
  sensitive = true
}

# Module-specific variables
variable "hosted_zone" { type = string }
variable "record_name" { type = string }
variable "record_value" { type = string }
