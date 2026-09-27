data "aws_eks_cluster_auth" "addons" {
  name = var.eks_addons_cluster_name
}

# ============================================================
# HELM PROVIDER CONFIGURATION
# ============================================================
provider "helm" {
  # FIX: Restored the proper assignment operator (=) for the configuration map
  kubernetes = {
    host                   = module.eks["main"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks["main"].cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.eks_addons_cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# ============================================================
# KUBERNETES PROVIDER CONFIGURATION
# ============================================================
provider "kubernetes" {
  # FIX: Targeted the exact ["main"] index key to extract clean payload strings
  host                   = module.eks["main"].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks["main"].cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_addons_cluster_name,
      "--region",
      var.aws_region
    ]
  }
}
