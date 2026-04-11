output "rest_api_endpoint" {
  description = "API Gateway REST endpoint"
  value       = module.api_gw.rest_api_endpoint
}

output "websocket_api_endpoint" {
  description = "API Gateway WebSocket endpoint"
  value       = module.api_gw.websocket_api_endpoint
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = var.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool App Client ID"
  value       = var.cognito_user_pool_client_id
}

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = var.cognito_identity_pool_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain"
  value       = var.cognito_domain
}

output "dynamodb_table_names" {
  description = "Map of DynamoDB table names"
  value       = module.dynamodb.table_names
}

output "reports_bucket_name" {
  description = "S3 bucket for PDF reports"
  value       = module.storage.reports_bucket_name
}

output "notifications_topic_arn" {
  description = "SNS topic ARN for push notifications"
  value       = module.messaging.notifications_topic_arn
}

output "api_lambda_function_name" {
  description = "Monolithic API Lambda function name"
  value       = module.lambda.api_lambda_function_name
}

output "ws_lambda_function_name" {
  description = "WebSocket handler Lambda function name"
  value       = module.lambda.ws_lambda_function_name
}

output "alert_checker_lambda_function_name" {
  description = "Alert checker scheduled Lambda function name"
  value       = module.lambda.alert_checker_lambda_function_name
}
