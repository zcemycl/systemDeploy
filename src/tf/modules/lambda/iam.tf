resource "aws_iam_role" "this" {
  for_each           = var.lambda_funcs
  name               = "${var.prefix}-${each.key}-iam-role"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_policy" "this" {
  for_each = var.lambda_funcs
  name     = "${var.prefix}-${each.key}-iam-policy"
  policy   = file("${path.module}/iam/${each.value.policy_document_name}")
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.lambda_funcs
  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "aws_iam_role" "this_schedule" {
  for_each           = { for name, obj in var.lambda_funcs : name => obj if obj.enable_schedule }
  name               = "${var.prefix}-${each.key}-schedule-iam-role"
  assume_role_policy = file("${path.module}/iam/scheduler_assume_policy.json")
}

resource "aws_iam_role_policy" "this_schedule" {
  for_each = { for name, obj in var.lambda_funcs : name => obj if obj.enable_schedule }
  name     = "${var.prefix}-${each.key}-schedule-iam-role-policy"
  role     = aws_iam_role.this_schedule[each.key].id
  policy   = file("${path.module}/iam/scheduler_role_policy.json")
}
