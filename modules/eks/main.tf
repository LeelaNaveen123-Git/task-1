# ============================================================
# EKS MODULE
# ============================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  # ==========================================================
  # CLUSTER
  # ==========================================================

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id = var.vpc_id

  subnet_ids = values(
    var.private_subnet_ids
  )

  control_plane_subnet_ids = values(
    var.control_plane_subnet_ids
  )

  # ==========================================================
  # EKS API ENDPOINT
  # ==========================================================

  endpoint_public_access = var.endpoint_public_access

  endpoint_private_access = var.endpoint_private_access

  endpoint_public_access_cidrs = var.public_access_cidrs

  # ==========================================================
  # CLUSTER IAM ROLE
  # ==========================================================

  create_iam_role = false

  iam_role_arn = var.cluster_iam_role_arn

  iam_role_additional_policies = (
    var.cluster_iam_role_additional_policies
  )

  # ==========================================================
  # EKS ACCESS
  # ==========================================================

  authentication_mode = "API_AND_CONFIG_MAP"

  enable_cluster_creator_admin_permissions = true

  access_entries = var.access_entries

  # ==========================================================
  # KMS ENCRYPTION
  # ==========================================================

  create_kms_key = var.create_kms_key

  enable_kms_key_rotation = true

  encryption_config = var.create_kms_key ? {
    resources = [
      "secrets"
    ]
  } : null

  # ==========================================================
  # EKS ADDONS
  # ==========================================================

  addons = {
    for addon, config in var.cluster_addons :
    addon => {
      most_recent = config.most_recent
    }
  }

  # ==========================================================
  # EKS MANAGED NODE GROUPS
  # ==========================================================

  eks_managed_node_groups = {

    for name, node_group in var.node_groups :

    name => {

      # ------------------------------------------------------
      # CUSTOM AMI
      # ------------------------------------------------------

      ami_id = try(
        node_group.ami_id,
        null
      )

      # ------------------------------------------------------
      # INSTANCE
      # ------------------------------------------------------

      instance_types = node_group.instance_types

      capacity_type = node_group.capacity_type

      # ------------------------------------------------------
      # SCALING
      # ------------------------------------------------------

      min_size = node_group.min_size

      max_size = node_group.max_size

      desired_size = node_group.desired_size

      # ------------------------------------------------------
      # SUBNETS
      # ------------------------------------------------------

      subnet_ids = values(
        var.private_subnet_ids
      )

      # ------------------------------------------------------
      # IAM
      # ------------------------------------------------------

      create_iam_role = false

      iam_role_arn = node_group.iam_role_arn

      iam_role_additional_policies = (
        node_group.iam_role_additional_policies
      )

      # ------------------------------------------------------
      # LAUNCH TEMPLATE
      # ------------------------------------------------------

      create_launch_template = true

      use_custom_launch_template = true

      launch_template_name = (
        node_group.launch_template_name
      )

      launch_template_description = (
        "Launch template for ${var.cluster_name}-${name}"
      )

      # ------------------------------------------------------
      # CUSTOM AMI BOOTSTRAP
      # ------------------------------------------------------
      #
      # IMPORTANT:
      # For a custom AMI that is derived from an AWS EKS
      # Optimized AMI, enable the module-provided bootstrap.
      #
      # Do NOT set:
      #
      # ami_type = "CUSTOM"
      #
      # because CUSTOM is not a supported ami_type for the
      # module's user-data template lookup.
      #
      enable_bootstrap_user_data = true

      # ------------------------------------------------------
      # INSTANCE METADATA
      # ------------------------------------------------------

      metadata_options = {
        http_endpoint = "enabled"

        http_tokens = "required"

        http_put_response_hop_limit = 2

        instance_metadata_tags = "disabled"
      }

      # ------------------------------------------------------
      # ROOT EBS VOLUME
      # ------------------------------------------------------

      block_device_mappings = {

        root = {

          device_name = "/dev/xvda"

          ebs = {

            volume_size = node_group.disk_size

            volume_type = "gp3"

            encrypted = true

            delete_on_termination = true
          }
        }
      }

      # ------------------------------------------------------
      # MONITORING
      # ------------------------------------------------------

      enable_monitoring = true

      # ------------------------------------------------------
      # TAGS
      # ------------------------------------------------------

      tags = merge(
        var.tags,
        {
          Name = "${var.cluster_name}-${name}"

          Cluster = var.cluster_name

          NodeGroup = name

          ManagedBy = "Terraform"
        }
      )
    }
  }

  # ==========================================================
  # CLUSTER TAGS
  # ==========================================================

  tags = var.tags
}