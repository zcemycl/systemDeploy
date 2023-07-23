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