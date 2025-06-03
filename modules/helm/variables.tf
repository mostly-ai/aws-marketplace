# Module-specific variables
variable "service" {
  type    = string
  default = "mostlyai"
}
variable "helm_release_repository" {
  type    = string
  default = "https://709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
}
variable "helm_release_version" {
  type    = string
  default = "4.6.2"
}
variable "helm_release_values" {
  type    = map(any)
  default = {}
}
variable "helm_release_secret_values" {
  type      = map(any)
  default   = {}
  sensitive = true
}
