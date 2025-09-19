# Global variables provisioned by Terragrunt
variable "global" { type = map(string) }
variable "global_secret" {
  type      = map(string)
  sensitive = true
}

# Module-specific variables
variable "service" {
  type    = string
  default = "s3"
}
variable "s3_buckets" {
  type = map(object({
    acl                       = string
    force_destroy             = bool
    lifecycle_status          = string
    lifecycle_expiration_days = number
    block_public_acls         = bool
    block_public_policy       = bool
    ignore_public_acls        = bool
    restrict_public_buckets   = bool
    bucket_policy             = optional(string, null)
  }))
}
