resource "aws_iam_user" "service_publisher" {
    name = "service-publisher"
}

resource "aws_iam_access_key" "service_publisher" {
    user = aws_iam_user.service_publisher.name
}