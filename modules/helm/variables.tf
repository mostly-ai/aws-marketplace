# Module-specific variables
variable "service" {
  type    = string
  default = "mostlyai"
}
variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}
variable "helm_release_repository" {
  type    = string
  default = "https://709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
}
variable "helm_release_version" {
  type    = string
  default = "4.7.0"
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
