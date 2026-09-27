resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  create_namespace = false

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  wait    = true
  timeout = 600
  # ============================================================
  # CLEAN VALUES BLOCK (BYPASSES ALL SET SYNTAX ERRORS)
  # ============================================================
  values = [
    yamlencode({
      replicas = 1

      settings = {
        clusterName = var.cluster_name
        # REMOVED SQS QUEUE TO UNBLOCK THE INITIALIZATION LOOP
      }
      serviceAccount = {
        name = "karpenter"
      }
      controller = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
    })
  ]
  # ============================================================
  # DEPENDENCIES
  # ============================================================
  depends_on = [
    aws_iam_role_policy_attachment.karpenter_controller_extra
  ]
}
