resource "aws_sqs_queue" "karpenter_interruption" {
  name = "${var.cluster_name}-karpenter"

  message_retention_seconds = 300

  sqs_managed_sse_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.cluster_name}-karpenter"
      Component = "karpenter"
      ManagedBy = "Terraform"
    }
  )
}

data "aws_iam_policy_document" "karpenter_queue" {
  statement {
    sid    = "AllowEventBridgeSendMessage"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "events.amazonaws.com"
      ]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]
  }

  statement {
    sid    = "DenyUnsecureTransport"
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*"
      ]
    }

    actions = [
      "sqs:*"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.url

  policy = data.aws_iam_policy_document.karpenter_queue.json
}

resource "aws_cloudwatch_event_rule" "karpenter_spot" {
  name = "${var.cluster_name}-karpenter-spot"

  event_pattern = jsonencode({
    source = [
      "aws.ec2"
    ]

    "detail-type" = [
      "EC2 Spot Instance Interruption Warning"
    ]
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "karpenter_spot" {
  rule = aws_cloudwatch_event_rule.karpenter_spot.name

  arn = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "karpenter_rebalance" {
  name = "${var.cluster_name}-karpenter-rebalance"

  event_pattern = jsonencode({
    source = [
      "aws.ec2"
    ]

    "detail-type" = [
      "EC2 Instance Rebalance Recommendation"
    ]
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "karpenter_rebalance" {
  rule = aws_cloudwatch_event_rule.karpenter_rebalance.name

  arn = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "karpenter_state_change" {
  name = "${var.cluster_name}-karpenter-state-change"

  event_pattern = jsonencode({
    source = [
      "aws.ec2"
    ]

    "detail-type" = [
      "EC2 Instance State-change Notification"
    ]
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "karpenter_state_change" {
  rule = aws_cloudwatch_event_rule.karpenter_state_change.name

  arn = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name = var.cluster_name

  namespace = "kube-system"

  service_account = "karpenter"

  role_arn = aws_iam_role.karpenter_controller.arn

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.cluster_name}-karpenter-pod-identity"
      Component = "karpenter"
      ManagedBy = "Terraform"
    }
  )
}
