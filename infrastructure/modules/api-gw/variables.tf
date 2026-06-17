variable "project_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }

variable "api_lambda_arn" { type = string }
variable "api_lambda_invoke_arn" { type = string }
variable "api_lambda_function_name" { type = string }

variable "ws_lambda_arn" { type = string }
variable "ws_lambda_invoke_arn" { type = string }
variable "ws_lambda_function_name" { type = string }

# WebSocket API is created in the root module to break a dependency cycle
# (lambda module needs the WS endpoint as an env var). This module attaches
# integrations, routes, stage, and permissions to the externally-created API.
variable "ws_api_id" { type = string }
variable "ws_api_execution_arn" { type = string }
