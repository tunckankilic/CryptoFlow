locals {
  prefix = "${var.project_name}-${var.environment}"
}

resource "aws_sns_topic" "notifications" {
  name = "${local.prefix}-notifications"
}

# NOTE: APNs / FCM platform applications are NOT created here.
# They require credentials (APNs cert/key, FCM server key) that will be
# uploaded manually or via a separate secret-aware pipeline in Faz 2.
# Their ARNs will then be referenced as additional resources or imported.
