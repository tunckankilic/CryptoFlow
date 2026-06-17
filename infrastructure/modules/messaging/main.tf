locals {
  prefix = "${var.project_name}-${var.environment}"
}

resource "aws_sns_topic" "notifications" {
  name = "${local.prefix}-notifications"
}

# --- APNs platform application (token-based authentication) ---
# Token-based auth: the .p8 file contents are stored in SSM Parameter Store as
# a SecureString. We read it here and feed it into the platform application.
data "aws_ssm_parameter" "apns_signing_key" {
  name            = var.apns_signing_key_ssm_parameter
  with_decryption = true
}

resource "aws_sns_platform_application" "apns" {
  name     = "${local.prefix}-apns"
  platform = var.apns_use_sandbox ? "APNS_SANDBOX" : "APNS"

  # Token-based authentication fields:
  #   platform_principal  → APNs Signing Key ID
  #   platform_credential → contents of the .p8 private key file
  platform_principal  = var.apns_signing_key_id
  platform_credential = data.aws_ssm_parameter.apns_signing_key.value

  apple_platform_team_id   = var.apns_team_id
  apple_platform_bundle_id = var.apns_bundle_id

  event_endpoint_created_topic_arn = aws_sns_topic.notifications.arn
  event_endpoint_deleted_topic_arn = aws_sns_topic.notifications.arn
  event_endpoint_updated_topic_arn = aws_sns_topic.notifications.arn
}
