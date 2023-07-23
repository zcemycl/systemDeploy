# simple user for pushing container to ecr
resource "aws_iam_user" "service_publisher" {
    name = "service-publisher"
}

resource "aws_iam_access_key" "service_publisher" {
    user = aws_iam_user.service_publisher.name
}

resource "aws_iam_policy" "service_publisher_policy" {
    name = "service-publish-policy"
    policy = file("policies/service-publish-policy.json")
}

resource "aws_iam_policy_attachment" "service_publisher_policy_attach" {
    name = "service-publish-policy-attach"
    users = [
        aws_iam_user.service_publisher.name
    ]
    policy_arn = aws_iam_policy.service_publisher_policy.arn
}

# developer group
locals {
    developers = {
        leo: {name = "leo"}, 
        yui: {name = "yui"}
    }
}

resource "aws_iam_user" "developers" {
    for_each = local.developers
    name = each.key
}

resource "aws_iam_group" "developers" {
    name  = "developers"
}

resource "aws_iam_group_membership" "developer_team" {
    name = "developer-team"
    users = [for u in aws_iam_user.developers : u.name]
    group = aws_iam_group.developers.name
}

resource "aws_iam_user_login_profile" "dev-users" {
    for_each = toset([for u in aws_iam_user.developers : u.name])
    user    = each.key
    # pgp_key = file("public.gpg")
}

resource "aws_iam_access_key" "dev_users" {
    for_each = toset([for u in aws_iam_user.developers : u.name])
    user    = each.key
}