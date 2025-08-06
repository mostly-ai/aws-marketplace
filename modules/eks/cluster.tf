module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.36.0"

  cluster_name    = "${var.global.environment}-${var.service}"
  iam_role_name   = "${var.global.environment}-${var.service}"
  cluster_version = var.eks_kubernetes_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_node_security_group               = false
  enable_cluster_creator_admin_permissions = true
  vpc_id                                   = var.vpc_id
  subnet_ids                               = concat(var.private_subnet_ids, var.eks_enable_public_subnets ? var.public_subnet_ids : [])
  control_plane_subnet_ids                 = concat(var.private_subnet_ids, var.eks_enable_public_subnets ? var.public_subnet_ids : [])
  enable_irsa                              = true

  cluster_addons = {
    coredns            = { most_recent = true }
    kube-proxy         = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
    vpc-cni = {
      most_recent          = true
      configuration_values = jsonencode({ enableNetworkPolicy = "true" })
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = "BOTTLEROCKET_x86_64"
    use_custom_launch_template = false
    create_security_group      = false
    subnet_ids                 = var.eks_enable_public_subnets ? var.public_subnet_ids : var.private_subnet_ids
    use_name_prefix            = true

    capacity_type              = "ON_DEMAND"
    create_iam_role            = true
    iam_role_attach_cni_policy = true
    iam_role_use_name_prefix   = true

    ebs_optimized     = true
    enable_monitoring = true
  }

  eks_managed_node_groups = merge(
    {
      "general-nodes" = {
        name                                  = "${var.global.environment}-${var.service}-general-nodes"
        instance_types                        = var.eks_general_node_group_instance_types
        use_custom_launch_template            = true
        attach_cluster_primary_security_group = true
        disk_size                             = 24
        subnet_ids                            = var.eks_enable_public_subnets ? var.public_subnet_ids : var.private_subnet_ids
        iam_role_name                         = "${var.global.environment}-general-nodes"
        iam_role_description                  = "IAM Role for MostlyAI EKS General Nodes"
        iam_role_additional_policies = {
          AWSMarketplaceMeteringRegisterUsage = "arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage",
          AmazonEBSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
          ALBControllerIAMPolicy              = aws_iam_policy.loadbalancer.arn
          MostlyServiceAuthPolicy             = aws_iam_policy.auth.arn
        }
        # * Note that after creation - desired size must be kept up-to-date manually
        # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#why-are-there-no-changes-when-a-node-groups-desired_size-is-modified
        min_size     = var.eks_general_node_group_min_size
        desired_size = var.eks_general_node_group_desired_size
        max_size     = var.eks_general_node_group_max_size
      },
      "cpu-compute-nodes" = {
        name                                  = "${var.global.environment}-${var.service}-cpu-compute-nodes"
        instance_types                        = var.eks_cpu_compute_node_group_instance_types
        use_custom_launch_template            = true
        attach_cluster_primary_security_group = true
        disk_size                             = 24
        subnet_ids                            = var.eks_enable_public_subnets ? var.public_subnet_ids : var.private_subnet_ids
        iam_role_name                         = "${var.global.environment}-cpu-compute-nodes"
        iam_role_description                  = "IAM Role for MostlyAI EKS CPU-Compute Nodes"
        # * Note that after creation - desired size must be kept up-to-date manually
        # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#why-are-there-no-changes-when-a-node-groups-desired_size-is-modified
        min_size     = var.eks_cpu_compute_node_group_min_size
        desired_size = var.eks_cpu_compute_node_group_desired_size
        max_size     = var.eks_cpu_compute_node_group_max_size
        taints = [
          {
            key    = "scheduling.mostly.ai/node"
            value  = "engine-jobs"
            effect = "NO_SCHEDULE"
          }
        ]
      },
    },
    var.eks_gpu_compute_node_group_enabled ? {
      "gpu-compute-nodes" = {
        name                                  = "${var.global.environment}-${var.service}-gpu-compute-nodes"
        instance_types                        = var.eks_gpu_compute_node_group_instance_types
        use_custom_launch_template            = true
        attach_cluster_primary_security_group = true
        disk_size                             = 24
        subnet_ids                            = var.eks_enable_public_subnets ? var.public_subnet_ids : var.private_subnet_ids
        iam_role_name                         = "${var.global.environment}-gpu-compute-nodes"
        iam_role_description                  = "IAM Role for MostlyAI EKS GPU-Compute Nodes"
        # * Note that after creation - desired size must be kept up-to-date manually
        # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#why-are-there-no-changes-when-a-node-groups-desired_size-is-modified
        min_size     = var.eks_gpu_compute_node_group_min_size
        desired_size = var.eks_gpu_compute_node_group_desired_size
        max_size     = var.eks_gpu_compute_node_group_max_size
        taints = [
          {
            key    = "scheduling.mostly.ai/node"
            value  = "engine-jobs-gpu"
            effect = "NO_SCHEDULE"
          }
        ]
      }
    } : {}
  )

  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/eks"
    "Name" : "${var.global.environment}-${var.service}"
  }
}
