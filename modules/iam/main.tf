data "aws_iam_policy_document" "assume_role" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        for service in var.trusted_services :
        "${service}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "this" {

  name = var.role_name

  description = var.description

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {

  for_each = toset(var.managed_policy_arns)

  role = aws_iam_role.this.name

  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {

  count = contains(var.trusted_services, "ec2") ? 1 : 0

  name = "${var.role_name}-profile"

  role = aws_iam_role.this.name

  tags = var.tags
}