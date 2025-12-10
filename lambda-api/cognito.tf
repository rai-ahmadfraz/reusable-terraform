resource "aws_cognito_user_pool" "this" {
  count = var.enable_cognito ? 1 : 0

  name = var.cognito_user_pool_name

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_client" "this" {
  count        = var.enable_cognito ? 1 : 0
  name         = var.cognito_app_client_name
  user_pool_id = aws_cognito_user_pool.this[0].id
  generate_secret = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}
