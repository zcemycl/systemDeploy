resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sagemaker:*",
      "logs:*",
      "s3:*",
      "iam:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role" "this_sagemaker" {
  assume_role_policy = data.aws_iam_policy_document.sagemaker_role.json
}

data "aws_iam_policy_document" "sagemaker_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sagemaker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sagemaker:*",
      "logs:*",
      "s3:*",
      "iam:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sagemaker_policy" {
  name   = "sagemaker-policy"
  policy = data.aws_iam_policy_document.sagemaker_policy.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_attach" {
  role       = aws_iam_role.this_sagemaker.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}
