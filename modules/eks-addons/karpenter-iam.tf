# ============================================================
# TRUST POLICIES / ASSUME ROLE DOCUMENTS
# ============================================================

data "aws_iam_policy_document" "karpenter_controller_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      # FIX: Restored the exact, clean string identifier for EKS Pod Identity
      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

data "aws_iam_policy_document" "karpenter_node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      # FIX: Restored the exact, clean string identifier for EC2 Subsystems
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

# ============================================================
# KARPENTER NODE ROLE & ATTACHMENTS
# ============================================================

resource "aws_iam_role" "karpenter_node" {
  name = "${var.cluster_name}-karpenter-node"

  assume_role_policy = (
    data.aws_iam_policy_document.karpenter_node_assume_role.json
  )

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.cluster_name}-karpenter-node"
      Component = "karpenter"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# KARPENTER CONTROLLER ROLE & ATTACHMENTS
# ============================================================

resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = (
    data.aws_iam_policy_document.karpenter_controller_assume_role.json
  )

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.cluster_name}-karpenter-controller"
      Component = "karpenter"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_iam_policy" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  description = "IAM policy for Karpenter controller"

  policy = file(
    "${path.module}/policies/karpenter-controller.json"
  )

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.cluster_name}-karpenter-controller-policy"
      Component = "karpenter"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role = aws_iam_role.karpenter_controller.name

  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# ============================================================
# EXTRA CONTROLLER PERMISSIONS (FIX FOR EKS, EC2, IAM, PRICING, & SQS)
# ============================================================

resource "aws_iam_policy" "karpenter_controller_extra" {
  name        = "${var.cluster_name}-karpenter-controller-extra"
  description = "Allows Karpenter to manage cluster nodes, IAM profiles, billing data, and SQS queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowEKSClusterDiscovery"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      },
      {
        Sid      = "AllowEC2FleetDiscoveryAndMutation"
        Effect   = "Allow"
        Action   = [
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:RunInstances",
          "ec2:TerminateInstances"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowIAMInstanceProfileManagement"
        Effect   = "Allow"
        Action   = [
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowAWSPriceDiscovery"
        Effect   = "Allow"
        Action   = [
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowSQSInterruptionQueueManagement"
        Effect   = "Allow"
        Action   = [
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_extra" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller_extra.arn
}
