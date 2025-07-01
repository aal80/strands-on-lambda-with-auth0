terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    auth0 = {
      source = "auth0/auth0"
      version = ">= 1.23.0"
    }
  }
}

provider "aws" {}

variable "auth0_domain" {}
variable "auth0_management_client_id" {}
variable "auth0_management_client_secret" {}

provider "auth0" {
  domain = var.auth0_domain
  client_id = var.auth0_management_client_id
  client_secret = var.auth0_management_client_secret
}
