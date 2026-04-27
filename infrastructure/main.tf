provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# WebSocket API is created here (not inside the api-gw module) so its endpoint
# can be passed into the lambda module as an environment variable. Without
# this, lambda → api_gw → lambda would form a dependency cycle. The api_gw
# module attaches integrations, routes, stage, and permissions to it.
resource "aws_apigatewayv2_api" "ws" {
  name                       = "${local.name_prefix}-ws"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

locals {
  ws_api_endpoint = "https://${aws_apigatewayv2_api.ws.id}.execute-api.${var.region}.amazonaws.com/${var.environment}"
}

module "cognito" {
  source = "./modules/cognito"

  project_name                       = var.project_name
  environment                        = var.environment
  cognito_user_pool_id               = var.cognito_user_pool_id
  cognito_user_pool_client_id        = var.cognito_user_pool_client_id
  cognito_identity_pool_id           = var.cognito_identity_pool_id
  cognito_domain                     = var.cognito_domain
  apple_team_id                      = var.apple_team_id
  apple_key_id                       = var.apple_key_id
  apple_service_id                   = var.apple_service_id
  apple_private_key_ssm_parameter    = var.apple_private_key_ssm_parameter
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

module "messaging" {
  source = "./modules/messaging"

  project_name                   = var.project_name
  environment                    = var.environment
  apns_team_id                   = var.apns_team_id
  apns_bundle_id                 = var.apns_bundle_id
  apns_signing_key_id            = var.apns_signing_key_id
  apns_signing_key_ssm_parameter = var.apns_signing_key_ssm_parameter
  apns_use_sandbox               = var.apns_use_sandbox
}

module "lambda" {
  source = "./modules/lambda"

  project_name              = var.project_name
  environment               = var.environment
  region                    = var.region
  dynamodb_table_arns       = module.dynamodb.table_arns
  dynamodb_table_names      = module.dynamodb.table_names
  reports_bucket_arn        = module.storage.reports_bucket_arn
  reports_bucket_name       = module.storage.reports_bucket_name
  notifications_topic_arn   = module.messaging.notifications_topic_arn
  apns_platform_app_arn     = module.messaging.apns_platform_application_arn
  cognito_user_pool_id      = var.cognito_user_pool_id
  cognito_user_pool_client  = var.cognito_user_pool_client_id
  ws_api_endpoint           = local.ws_api_endpoint
}

module "api_gw" {
  source = "./modules/api-gw"

  project_name             = var.project_name
  environment              = var.environment
  region                   = var.region
  api_lambda_arn           = module.lambda.api_lambda_arn
  api_lambda_invoke_arn    = module.lambda.api_lambda_invoke_arn
  api_lambda_function_name = module.lambda.api_lambda_function_name
  ws_lambda_arn            = module.lambda.ws_lambda_arn
  ws_lambda_invoke_arn     = module.lambda.ws_lambda_invoke_arn
  ws_lambda_function_name  = module.lambda.ws_lambda_function_name
  ws_api_id                = aws_apigatewayv2_api.ws.id
  ws_api_execution_arn     = aws_apigatewayv2_api.ws.execution_arn
}
