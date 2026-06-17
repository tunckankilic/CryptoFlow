variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "monthly_budget_usd" {
  description = "Monthly USD cap that triggers alarm emails."
  type        = string
  default     = "10"
}

variable "billing_alert_email" {
  description = "Email address that receives 50/80/100% budget alerts."
  type        = string
}
