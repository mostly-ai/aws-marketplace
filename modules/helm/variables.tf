# Module-specific variables
variable "service" {
  type    = string
  default = "mostlyai"
}
variable "namespace" {
  type    = string
  default = "mostlyai"
}
variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}
variable "helm_repository_auth_user" {
  type      = string
  sensitive = true
  default   = null
}
variable "helm_repository_auth_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "helm_release_repository" {
  type    = string
  default = "https://709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
}
variable "helm_release_version" {
  type    = string
  default = null
}
variable "helm_release_timeout" {
  type    = number
  default = 300
}
variable "helm_release_chart" {
  type    = string
  default = "mostly-combined"
}
variable "helm_release_values" {
  type = map(any)
  default = { values = {
    _placeholder = "No values provided"
  } }
}
variable "helm_release_secret_values" {
  type = map(any)
  default = { values = {
    _secret_placeholder = "No secret values provided"
  } }
  sensitive = true
}

variable "helm_release_deploy_enabled" {
    type = bool
    default = false
}
