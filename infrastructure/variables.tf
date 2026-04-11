variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name prefix used for resource naming"
  type        = string
  default     = "cryptoflow"
}

# --- Existing Cognito (created manually outside Terraform) ---

variable "cognito_user_pool_id" {
  description = "Existing Cognito User Pool ID"
  type        = string
  default     = "eu-central-1_tcCDzZ2mW"
}

variable "cognito_user_pool_client_id" {
  description = "Existing Cognito App Client ID"
  type        = string
  default     = "ce38mk4k08iib39on8elprsll"
}

variable "cognito_identity_pool_id" {
  description = "Existing Cognito Identity Pool ID"
  type        = string
  default     = "eu-central-1:26ad2164-44a2-48ac-a11b-1c1db9884944"
}

variable "cognito_domain" {
  description = "Existing Cognito hosted UI domain"
  type        = string
  default     = "eu-central-1tccdz2mw.auth.eu-central-1.amazoncognito.com"
}

# --- Apple Sign-In (Sign in with Apple) ---

variable "apple_team_id" {
  description = "Apple Team ID for Sign in with Apple"
  type        = string
  default     = "J2T55ML92H"
}

variable "apple_key_id" {
  description = "Apple Key ID for Sign in with Apple"
  type        = string
  default     = "UJ875F944W"
}

variable "apple_service_id" {
  description = "Apple Service ID (client_id) for Sign in with Apple"
  type        = string
  default     = "site.tunckankilic.cryptoFlow.auth"
}

variable "apple_private_key_ssm_parameter" {
  description = "SSM Parameter Store name holding the Apple private key (.p8 contents)"
  type        = string
  default     = "/cryptoflow/auth/apple/private_key"
}

# --- Google Sign-In ---

variable "google_client_id_ssm_parameter" {
  description = "SSM Parameter Store name holding the Google OAuth client_id"
  type        = string
  default     = "/cryptoflow/auth/google/client_id"
}

variable "google_client_secret_ssm_parameter" {
  description = "SSM Parameter Store name holding the Google OAuth client_secret"
  type        = string
  default     = "/cryptoflow/auth/google/client_secret"
}
