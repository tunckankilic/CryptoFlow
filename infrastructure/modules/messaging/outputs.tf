output "notifications_topic_arn" {
  value = aws_sns_topic.notifications.arn
}

output "apns_platform_application_arn" {
  description = "ARN of the APNs SNS Platform Application (used by the API Lambda to CreatePlatformEndpoint)"
  value       = aws_sns_platform_application.apns.arn
}
