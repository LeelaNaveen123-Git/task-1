module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  # ============================================================
  # EKS CLUSTER
  # ============================================================

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # ============================================================
  # NETWORKING
  # ============================================================

  vpc_id = var.vpc_id

  subnet_ids = values(var.private_subnet_ids)

  control_plane_subnet_ids = values(
    var.control_plane_subnet_ids
  )

  # ============================================================
  # EKS API ENDPOINT
  # ============================================================

  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  endpoint_public_access_cidrs = var.public_access_cidrs

  # ============================================================
  # EXISTING CLUSTER IAM ROLE
  #
  # IMPORTANT:
  # We are reusing the existing IAM role.
  # Terraform must NOT create a new role.
  # ============================================================

  create_iam_role = false

  iam_role_arn = var.cluster_iam_role_arn

  # Do not attach additional policies to the existing role
  iam_role_additional_policies = var.cluster_iam_role_additional_policies

  # ============================================================
  # EKS AUTHENTICATION
  # ============================================================

  authentication_mode = "API_AND_CONFIG_MAP"

  enable_cluster_creator_admin_permissions = true

  access_entries = var.access_entries

  # ============================================================
  # KMS ENCRYPTION
  # ============================================================

  create_kms_key = var.create_kms_key

  enable_kms_key_rotation = true

  encryption_config = var.create_kms_key ? {
    resources = ["secrets"]
  } : null

  # ============================================================
  # EKS ADD-ONS
  # ============================================================

  addons = {
    for addon, config in var.cluster_addons :
    addon => {
      most_recent = config.most_recent
    }
  }

  # ============================================================
  # EKS MANAGED NODE GROUPS
  # ============================================================

  eks_managed_node_groups = {
    for name, node_group in var.node_groups :

    name => {

      # --------------------------------------------------------
      # AMI
      # --------------------------------------------------------

      ami_type = "AL2023_x86_64_STANDARD"

      # --------------------------------------------------------
      # INSTANCE
      # --------------------------------------------------------

      instance_types = node_group.instance_types

      capacity_type = node_group.capacity_type

      # --------------------------------------------------------
      # SCALING
      # --------------------------------------------------------

      min_size     = node_group.min_size
      max_size     = node_group.max_size
      desired_size = node_group.desired_size

      # --------------------------------------------------------
      # SUBNETS
      # --------------------------------------------------------

      subnet_ids = values(var.private_subnet_ids)

      # --------------------------------------------------------
      # EXISTING NODE IAM ROLE
      #
      # IMPORTANT:
      # Do NOT create another IAM role.
      # --------------------------------------------------------

      create_iam_role = false

      iam_role_arn = node_group.iam_role_arn

      iam_role_additional_policies = (
        node_group.iam_role_additional_policies
      )

      # --------------------------------------------------------
      # LAUNCH TEMPLATE
      # --------------------------------------------------------

      create_launch_template    = true
      use_custom_launch_template = true

      launch_template_name = node_group.launch_template_name

      launch_template_description = (
        "Launch template for ${var.cluster_name}-${name}"
      )

      # --------------------------------------------------------
      # EC2 INSTANCE METADATA
      # --------------------------------------------------------

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      # --------------------------------------------------------
      # ROOT DISK
      # --------------------------------------------------------

      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"

          ebs = {
            volume_size           = node_group.disk_size
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # --------------------------------------------------------
      # EC2 MONITORING
      # --------------------------------------------------------

      enable_monitoring = true

      # --------------------------------------------------------
      # NODE TAGS
      # --------------------------------------------------------

      tags = merge(
        var.tags,
        {
          Name      = "${var.cluster_name}-${name}"
          Cluster   = var.cluster_name
          NodeGroup = name
          ManagedBy = "Terraform"
        }
      )
    }
  }

  # ============================================================
  # CLUSTER TAGS
  # ============================================================

  tags = var.tags
}