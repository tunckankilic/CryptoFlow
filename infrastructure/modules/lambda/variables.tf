variable "project_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs the Lambdas can access"
  type        = list(string)
}

variable "dynamodb_table_names" {
  description = "Map of logical name to DynamoDB table name"
  type        = map(string)
}

variable "reports_bucket_arn" {
  type = string
}

variable "reports_bucket_name" {
  type = string
}

variable "notifications_topic_arn" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_user_pool_client" {
  type = string
}

variable "ws_api_endpoint" {
  description = "WebSocket API HTTPS endpoint for @connections POST (e.g. https://abc.execute-api.eu-central-1.amazonaws.com/dev)"
  type        = string
}
