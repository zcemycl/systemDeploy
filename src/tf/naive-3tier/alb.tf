resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_groups.alb_sg_id]
  subnets            = module.alb_network.subnets.*.id

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  idle_timeout               = 180

  #   access_logs {
  #     bucket  = aws_s3_bucket.alb.bucket
  #     prefix  = "alb-logs"
  #     enabled = true
  #   }
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.base_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "180"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "120"
    path                = "/"
    port                = "80"
    unhealthy_threshold = "2"
  }

  depends_on = [
    aws_lb.alb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.certificate_app.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavaliable"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "app_https" {
  listener_arn = aws_lb_listener.https.arn
  action {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [var.application_domain, "www.${var.application_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "cors_rule" {
  listener_arn = aws_lb_listener.https.arn
  action {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    type             = "forward"
  }
  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }
}

# logs for alb
# resource "aws_s3_bucket" "alb" {
#   bucket = "alb-bucket-leo-060923"
#   acl    = "private"
# }

# data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket_policy" "b" {
#   bucket = aws_s3_bucket.alb.id

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "s3:PutObject",
#       "Principal": {
#         "AWS": "${aws_lb.alb.arn}"
#       },
#       "Resource": "${aws_s3_bucket.alb.id}/alb-logs/AWSLogs/data.aws_caller_identity.current.account_id/*",
#       "Effect": "Allow"
#     }
#   ]
# }
# POLICY
# }
