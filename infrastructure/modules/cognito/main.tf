# Existing Cognito User Pool was created manually outside Terraform.
# We attach to it via data source so that downstream modules can reference its ARN.
data "aws_cognito_user_pools" "existing" {
  name = "cryptoflow-users"
}

# Read OAuth secrets from SSM at plan/apply time.
data "aws_ssm_parameter" "apple_private_key" {
  name            = var.apple_private_key_ssm_parameter
  with_decryption = true
}

data "aws_ssm_parameter" "google_client_id" {
  name            = var.google_client_id_ssm_parameter
  with_decryption = true
}

data "aws_ssm_parameter" "google_client_secret" {
  name            = var.google_client_secret_ssm_parameter
  with_decryption = true
}

# Federated identity providers attached to the existing user pool.
# These are managed by Terraform from Faz 0 onward.
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = var.cognito_user_pool_id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "openid email profile"
    client_id        = data.aws_ssm_parameter.google_client_id.value
    client_secret    = data.aws_ssm_parameter.google_client_secret.value
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_identity_provider" "apple" {
  user_pool_id  = var.cognito_user_pool_id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    authorize_scopes = "email name"
    client_id        = var.apple_service_id
    team_id          = var.apple_team_id
    key_id           = var.apple_key_id
    private_key      = data.aws_ssm_parameter.apple_private_key.value
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}
