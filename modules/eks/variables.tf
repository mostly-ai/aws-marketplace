# Global variables provisioned by Terragrunt
variable "global" { type = map(string) }
variable "global_secret" {
  type      = map(string)
  sensitive = true
}

# Module-specific variables
variable "service" {
  type    = string
  default = "eks"
}
variable "mostly_s3_bucket_access_policy_name" { type = string }
variable "vpc_name" { type = string }
variable "vpc_public_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "vpc_private_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "eks_kubernetes_version" {
  type    = string
  default = null
}
variable "eks_enable_public_subnets" {
  type    = bool
  default = true

}

variable "eks_general_node_group_instance_types" {
  type    = list(string)
  default = ["m5a.xlarge"]
}
variable "eks_general_node_group_max_size" {
  type    = number
  default = 4
}
variable "eks_cpu_compute_node_group_instance_types" {
  type    = list(string)
  default = ["c5.4xlarge"]
}
variable "eks_cpu_compute_node_group_max_size" {
  type    = number
  default = 4
}
variable "eks_gpu_compute_node_group_instance_types" {
  type    = list(string)
  default = ["g5.2xlarge"]
}
variable "eks_gpu_compute_node_group_max_size" {
  type    = number
  default = 4
}
