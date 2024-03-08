data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "leo-test-sagemaker-bucket"
}

resource "aws_sagemaker_domain" "example" {
  domain_name = "leo-test-sagemaker"
  auth_mode   = "IAM"
  vpc_id      = data.aws_vpc.selected.id
  subnet_ids  = data.aws_subnets.selected.ids

  default_user_settings {
    execution_role  = aws_iam_role.sagemaker_role.arn
    security_groups = [aws_security_group.this.id]

    jupyter_server_app_settings {
      default_resource_spec {
        instance_type       = "system"
        sagemaker_image_arn = "arn:aws:sagemaker:eu-west-2:712779665605:image/jupyter-server-3"
      }
    }

    sharing_settings {
      notebook_output_option = "Allowed"
    }

    canvas_app_settings {
      model_register_settings {
        status = "DISABLED"
      }

      time_series_forecasting_settings {
        status = "DISABLED"
      }
    }
  }

  domain_settings {
    security_group_ids = [aws_security_group.this.id]
  }
}

resource "aws_sagemaker_user_profile" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = "leo-leung"
}

resource "aws_sagemaker_app" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = aws_sagemaker_user_profile.example.user_profile_name
  app_name          = "default"
  app_type          = "JupyterServer"
}

resource "aws_sagemaker_notebook_instance" "ni" {
  name          = "leo-notebook-instance"
  role_arn      = aws_iam_role.sagemaker_role.arn
  instance_type = "ml.t2.medium"
}
