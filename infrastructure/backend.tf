terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket         = "cryptoflow-terraform-state"
    key            = "cryptoflow/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "cryptoflow-terraform-locks"
    encrypt        = true
  }
}
