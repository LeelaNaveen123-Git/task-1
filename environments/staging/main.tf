# ============================================================
# VPC
# ============================================================

module "vpc" {
  for_each = var.vpcs

  source = "../../modules/vpc"

  name = "${var.project_name}-${var.environment}-${each.key}"

  cidr_block = each.value.cidr_block

  azs = each.value.azs

  public_subnets = each.value.public_subnets

  private_subnets = each.value.private_subnets

  enable_nat_gateway = each.value.enable_nat_gateway

  single_nat_gateway = each.value.single_nat_gateway

  enable_dns_support = each.value.enable_dns_support

  enable_dns_hostnames = each.value.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    {
      VPC = each.key
    }
  )
}


# ============================================================
# SECURITY GROUPS
# ============================================================

module "security_group" {
  for_each = var.security_groups

  source = "../../modules/security-group"

  name = "${var.project_name}-${var.environment}-${each.key}"

  description = each.value.description

  vpc_id = module.vpc[
    each.value.vpc_name
  ].vpc_id

  ingress_rules = each.value.ingress_rules

  egress_rules = each.value.egress_rules

  tags = merge(
    var.common_tags,
    {
      VPC = each.value.vpc_name
    }
  )
}


# ============================================================
# S3
# ============================================================

module "s3" {
  for_each = var.s3_buckets

  source = "../../modules/s3"

  bucket_name = each.value.bucket_name

  versioning_enabled = each.value.enable_versioning

  kms_key_arn = each.value.kms_key_arn

  noncurrent_version_expiration_days = (
    each.value.noncurrent_version_expiration_days
  )

  tags = merge(
    var.common_tags,
    {
      Bucket = each.key
    }
  )
}


# ============================================================
# IAM
# ============================================================

module "iam" {
  for_each = var.iam_roles

  source = "../../modules/iam"

  role_name = "${var.project_name}-${var.environment}-${each.key}"

  description = each.value.description

  trusted_services = each.value.trusted_services

  managed_policy_arns = each.value.managed_policy_arns

  tags = merge(
    var.common_tags,
    {
      Role = each.key
    }
  )
}


# ============================================================
# EC2
# ============================================================

module "ec2" {
  for_each = var.ec2_instances

  source = "../../modules/ec2"

  name = "${var.project_name}-${var.environment}-${each.key}"

  ami_id = each.value.ami_id

  instance_type = each.value.instance_type

  subnet_id = lookup(
    module.vpc[each.value.vpc_name].private_subnet_ids,
    each.value.availability_zone
  )

  security_group_ids = [
    for sg_name in each.value.security_groups :
    module.security_group[sg_name].security_group_id
  ]

  associate_public_ip = each.value.associate_public_ip

  key_name = each.value.key_name

  iam_instance_profile = null

  root_volume_size = each.value.root_volume_size

  root_volume_type = each.value.root_volume_type

  monitoring = each.value.monitoring

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${each.key}"
    }
  )
}


# ============================================================
# EKS
# ============================================================

module "eks" {
  for_each = var.eks_clusters

  source = "../../modules/eks"

  cluster_name = "${var.project_name}-${var.environment}-${each.key}"

  kubernetes_version = each.value.kubernetes_version

  vpc_id = module.vpc[
    each.value.vpc_name
  ].vpc_id

  private_subnet_ids = module.vpc[
    each.value.vpc_name
  ].private_subnet_ids

  control_plane_subnet_ids = module.vpc[
    each.value.vpc_name
  ].private_subnet_ids

  endpoint_public_access = (
    each.value.endpoint_public_access
  )

  endpoint_private_access = (
    each.value.endpoint_private_access
  )

  public_access_cidrs = (
    each.value.public_access_cidrs
  )

  cluster_iam_role_arn = (
    each.value.cluster_iam_role_arn
  )

  cluster_iam_role_additional_policies = (
    each.value.cluster_iam_role_additional_policies
  )

  create_kms_key = each.value.create_kms_key

  cluster_addons = each.value.cluster_addons

  node_groups = each.value.node_groups

  access_entries = each.value.access_entries

  tags = merge(
    var.common_tags,
    {
      Cluster = each.key
    }
  )
}