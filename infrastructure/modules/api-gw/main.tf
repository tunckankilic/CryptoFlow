locals {
  prefix     = "${var.project_name}-${var.environment}"
  stage_name = var.environment
}

# =============================================================================
# Account-level CloudWatch Logs role
# API Gateway requires an IAM role at the account/region level before any
# stage with access logging can be created. This is a singleton per region.
# =============================================================================
data "aws_iam_policy_document" "apigw_cw_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apigw_cloudwatch" {
  name               = "${local.prefix}-apigw-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.apigw_cw_assume.json
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}

# =============================================================================
# REST API (HTTP API v2 — proxy to monolithic Lambda)
# =============================================================================
resource "aws_apigatewayv2_api" "rest" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Requested-With"]
    max_age       = 3600
  }
}

resource "aws_apigatewayv2_integration" "api_lambda" {
  api_id                 = aws_apigatewayv2_api.rest.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.api_lambda_invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.rest.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda.id}"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.rest.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda.id}"
}

resource "aws_cloudwatch_log_group" "rest_access" {
  name              = "/aws/apigw/${local.prefix}-rest"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "rest" {
  api_id      = aws_apigatewayv2_api.rest.id
  name        = local.stage_name
  auto_deploy = true

  # Tight throttle for cost protection. Rejects at the gateway before invoking
  # the Lambda, which means rejected requests cost ~nothing. Combined with the
  # Lambda reserved_concurrent_executions cap, this bounds the worst-case bill
  # under a flood.
  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 20
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.rest_access.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  depends_on = [aws_api_gateway_account.this]
}

resource "aws_lambda_permission" "rest_invoke" {
  statement_id  = "AllowAPIGatewayInvokeREST"
  action        = "lambda:InvokeFunction"
  function_name = var.api_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.rest.execution_arn}/*/*"
}

# =============================================================================
# WebSocket API attachments
# (The aws_apigatewayv2_api.ws resource itself lives in the root module to
# break a lambda ↔ api_gw dependency cycle. We attach integrations/routes/
# stage/permissions to it via var.ws_api_id.)
# =============================================================================
resource "aws_apigatewayv2_integration" "ws_lambda" {
  api_id                    = var.ws_api_id
  integration_type          = "AWS_PROXY"
  integration_uri           = var.ws_lambda_invoke_arn
  content_handling_strategy = "CONVERT_TO_TEXT"
}

resource "aws_apigatewayv2_route" "ws_connect" {
  api_id    = var.ws_api_id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_lambda.id}"
}

resource "aws_apigatewayv2_route" "ws_disconnect" {
  api_id    = var.ws_api_id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.ws_lambda.id}"
}

resource "aws_apigatewayv2_route" "ws_default" {
  api_id    = var.ws_api_id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.ws_lambda.id}"
}

resource "aws_cloudwatch_log_group" "ws_access" {
  name              = "/aws/apigw/${local.prefix}-ws"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "ws" {
  api_id      = var.ws_api_id
  name        = local.stage_name
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 20
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.ws_access.arn
    format = jsonencode({
      requestId    = "$context.requestId"
      ip           = "$context.identity.sourceIp"
      requestTime  = "$context.requestTime"
      routeKey     = "$context.routeKey"
      status       = "$context.status"
      connectionId = "$context.connectionId"
    })
  }

  depends_on = [aws_api_gateway_account.this]
}

resource "aws_lambda_permission" "ws_invoke" {
  statement_id  = "AllowAPIGatewayInvokeWS"
  action        = "lambda:InvokeFunction"
  function_name = var.ws_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.ws_api_execution_arn}/*/*"
}
