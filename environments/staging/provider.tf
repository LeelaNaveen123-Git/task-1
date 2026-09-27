provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}


# ============================================================
# EXISTING EKS CLUSTER
# ============================================================

data "aws_eks_cluster" "main" {
  name = module.eks["main"].cluster_name

  depends_on = [
    module.eks
  ]
}


data "aws_eks_cluster_auth" "main" {
  name = module.eks["main"].cluster_name

  depends_on = [
    module.eks
  ]
}


# ============================================================
# KUBERNETES PROVIDER
# ============================================================

provider "kubernetes" {
  host = data.aws_eks_cluster.main.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.main.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.main.token
}


# ============================================================
# HELM PROVIDER
# ============================================================

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.main.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.main.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.main.token
  }
}