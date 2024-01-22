resource "aws_iam_role" "sagemaker_role" {
  name               = "leo_sagemaker_role"
  assume_role_policy = file("iam/sagemaker_assume_policy.json")
}

resource "aws_iam_role_policy" "sagemaker_role_policy" {
  name   = "leo_sagemaker_role_policy"
  role   = aws_iam_role.sagemaker_role.id
  policy = file("iam/sagemaker_role_policy.json")
}
