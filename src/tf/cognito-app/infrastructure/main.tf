resource "aws_cognito_user_pool" "this" {
  name = var.project_name

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  alias_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  password_policy {
    minimum_length    = 8
    require_numbers   = false
    require_uppercase = false
    require_symbols   = false
  }

  lambda_config {
    create_auth_challenge          = ""
    define_auth_challenge          = ""
    verify_auth_challenge_response = ""
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${var.project_name}-client"

  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = ["CUSTOM_AUTH_FLOW_ONLY"]

  prevent_user_existence_errors = "ENABLED"

  token_validity_units {
    access_token  = "minutes"
    refresh_token = "minutes"
    id_token      = "minutes"
  }

  access_token_validity  = 15
  refresh_token_validity = 240
  id_token_validity      = 15
}
