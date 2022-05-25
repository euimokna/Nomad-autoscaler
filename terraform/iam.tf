resource "aws_iam_instance_profile" "nomad_server" {
  name        = "nomad_server_proflie"
  role        = aws_iam_role.nomad_server.name
}

resource "aws_iam_role" "nomad_server" {
  name               = "nomad_server_autoscaler"
  assume_role_policy = data.aws_iam_policy_document.nomad_server_assume.json
}


resource "aws_iam_role_policy" "nomad_server" {
  name   = "nomad_server_autoscaler"
  role   = aws_iam_role.nomad_server.id
  policy = data.aws_iam_policy_document.nomad_server.json
}

data "aws_iam_policy_document" "nomad_server_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "nomad_server" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeScalingActivities", #반드시 추가해야 함.
      "autoscaling:UpdateAutoScalingGroup", 
    ]

    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "nomad_client" {
  name        = "nomad_client_proflie"
  role        = aws_iam_role.nomad_client.name
}

resource "aws_iam_role" "nomad_client" {
  name               = "nomad_client_autoscaler"
  assume_role_policy = data.aws_iam_policy_document.nomad_client_assume.json
}

resource "aws_iam_role_policy" "nomad_client" {
  name   = "nomad_client_autoscaler"
  role   = aws_iam_role.nomad_client.id
  policy = data.aws_iam_policy_document.nomad_client.json
}

data "aws_iam_policy_document" "nomad_client_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "nomad_client" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }
}