locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Used to anchor IAM resource ARNs to this account specifically, instead of
# wildcarding the account ID segment.
data "aws_caller_identity" "current" {}

# --- Placeholder zip ---
data "archive_file" "placeholder" {
  type        = "zip"
  source_dir  = "${path.module}/placeholder"
  output_path = "${path.module}/placeholder.zip"
}

# --- IAM ---
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.prefix}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_inline" {
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
    ]
    resources = var.dynamodb_table_arns
  }

  statement {
    sid       = "S3Reports"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.reports_bucket_arn}/*"]
  }

  statement {
    sid       = "S3ListReports"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.reports_bucket_arn]
  }

  statement {
    sid       = "SNSTopicPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.notifications_topic_arn]
  }

  statement {
    sid    = "SNSPlatformEndpointManage"
    effect = "Allow"
    actions = [
      "sns:CreatePlatformEndpoint",
      "sns:DeleteEndpoint",
      "sns:GetEndpointAttributes",
      "sns:SetEndpointAttributes",
    ]
    resources = [var.apns_platform_app_arn]
  }

  statement {
    sid    = "SNSPlatformEndpointPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetEndpointAttributes",
    ]
    # Per-device endpoint ARNs are derived from the platform application ARN
    # (arn:aws:sns:region:account:endpoint/APNS*/<app-name>/<endpoint-uuid>).
    # Scoped to this account so a misconfigured policy can't reach foreign endpoints.
    resources = ["arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:endpoint/APNS*/${local.prefix}-apns/*"]
  }

  statement {
    sid       = "ApiGwManageConnections"
    effect    = "Allow"
    actions   = ["execute-api:ManageConnections"]
    # Scoped to this account and this specific WebSocket API.
    resources = ["arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.ws_api_id}/*/*/@connections/*"]
  }

  statement {
    sid    = "CognitoRead"
    effect = "Allow"
    actions = [
      "cognito-idp:GetUser",
      "cognito-idp:AdminGetUser",
    ]
    resources = ["arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.prefix}-lambda-inline"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_inline.json
}

# --- Log groups ---
resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${local.prefix}-api"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "ws" {
  name              = "/aws/lambda/${local.prefix}-ws-handler"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "alert_checker" {
  name              = "/aws/lambda/${local.prefix}-alert-checker"
  retention_in_days = 14
}

# --- Common environment ---
locals {
  common_env = {
    NODE_ENV                = var.environment
    AWS_REGION_NAME         = var.region
    COGNITO_USER_POOL_ID    = var.cognito_user_pool_id
    COGNITO_CLIENT_ID       = var.cognito_user_pool_client
    SNS_NOTIFICATIONS_TOPIC    = var.notifications_topic_arn
    SNS_APPLE_PLATFORM_APP_ARN = var.apns_platform_app_arn
    REPORTS_BUCKET          = var.reports_bucket_name
    DDB_USERS               = var.dynamodb_table_names["users"]
    DDB_USER_SETTINGS       = var.dynamodb_table_names["user_settings"]
    DDB_HOLDINGS            = var.dynamodb_table_names["portfolio_holdings"]
    DDB_TRANSACTIONS        = var.dynamodb_table_names["portfolio_transactions"]
    DDB_JOURNAL             = var.dynamodb_table_names["journal_entries"]
    DDB_ALERTS              = var.dynamodb_table_names["alerts"]
    DDB_WATCHLIST           = var.dynamodb_table_names["watchlist"]
    DDB_DEVICE_TOKENS       = var.dynamodb_table_names["device_tokens"]
    DDB_WS_CONNECTIONS      = var.dynamodb_table_names["ws_connections"]
    WS_API_ENDPOINT         = var.ws_api_endpoint
  }
}

# --- API Lambda (monolithic) ---
# reserved_concurrent_executions caps parallel invocations as a hard blast-radius
# limit: even under a flood, AWS will throttle to this many concurrent runs.
# Worst-case bill at 10×30s×512MB ≈ $0.0025/run, capped by API Gateway throttling.
resource "aws_lambda_function" "api" {
  function_name                  = "${local.prefix}-api"
  role                           = aws_iam_role.lambda_exec.arn
  runtime                        = "nodejs20.x"
  handler                        = "index.handler"
  filename                       = data.archive_file.placeholder.output_path
  source_code_hash               = data.archive_file.placeholder.output_base64sha256
  memory_size                    = 512
  timeout                        = 30
  reserved_concurrent_executions = 10

  environment {
    variables = local.common_env
  }

  depends_on = [aws_cloudwatch_log_group.api]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# --- WebSocket handler ---
resource "aws_lambda_function" "ws_handler" {
  function_name                  = "${local.prefix}-ws-handler"
  role                           = aws_iam_role.lambda_exec.arn
  runtime                        = "nodejs20.x"
  handler                        = "index.handler"
  filename                       = data.archive_file.placeholder.output_path
  source_code_hash               = data.archive_file.placeholder.output_base64sha256
  memory_size                    = 512
  timeout                        = 300
  reserved_concurrent_executions = 5

  environment {
    variables = local.common_env
  }

  depends_on = [aws_cloudwatch_log_group.ws]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# --- Alert checker (scheduled) ---
resource "aws_lambda_function" "alert_checker" {
  function_name    = "${local.prefix}-alert-checker"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  memory_size      = 512
  timeout          = 60

  environment {
    variables = local.common_env
  }

  depends_on = [aws_cloudwatch_log_group.alert_checker]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_cloudwatch_event_rule" "alert_checker_schedule" {
  name                = "${local.prefix}-alert-checker-schedule"
  description         = "Trigger alert checker every 1 minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "alert_checker_target" {
  rule      = aws_cloudwatch_event_rule.alert_checker_schedule.name
  target_id = "alert-checker"
  arn       = aws_lambda_function.alert_checker.arn
}

resource "aws_lambda_permission" "alert_checker_events" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alert_checker_schedule.arn
}
