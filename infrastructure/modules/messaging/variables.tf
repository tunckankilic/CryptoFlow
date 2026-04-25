variable "project_name" { type = string }
variable "environment" { type = string }

# --- APNs (Apple Push Notifications service) ---

variable "apns_team_id" {
  description = "Apple Developer Team ID (10 chars) — owner of the APNs Auth Key"
  type        = string
}

variable "apns_bundle_id" {
  description = "iOS app bundle identifier (matches Xcode Runner target)"
  type        = string
}

variable "apns_signing_key_id" {
  description = "Apple APNs Auth Key ID (10 chars) shown in the Keys section of the Apple Developer portal"
  type        = string
}

variable "apns_signing_key_ssm_parameter" {
  description = "SSM Parameter Store name (SecureString) holding the APNs .p8 file contents"
  type        = string
}

variable "apns_use_sandbox" {
  description = "When true, register the APNs platform application against the sandbox environment (development APNs). Use false for TestFlight/App Store builds."
  type        = bool
  default     = true
}
