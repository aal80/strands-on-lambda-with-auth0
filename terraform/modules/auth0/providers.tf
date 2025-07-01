variable "auth0_domain" {}
variable "auth0_management_client_id" {}

terraform {
  required_providers {
    auth0 = {
      source = "auth0/auth0"
      version = ">= 1.23.0"
    }
  }
}

