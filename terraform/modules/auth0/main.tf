locals {
  callback_uri         = "http://localhost:8000/callback"
  logout_url           = "http://localhost:8000/chat"
  client_name          = "Travel-Agent"
  app_type             = "regular_web"
  grant_types          = ["authorization_code", "refresh_token", "client_credentials"]
  jwt_alg              = "RS256"
  connection_name      = "Travel-Agent"
  user_password        = "Passw0rd@"
  resource_server_name = "Travel-Agent"
  resource_server_identifier = "https://travel-agent.example.com"
}
resource "random_string" "client_secret" {
  length  = 48
  upper   = true
  lower   = true
  numeric = true
  special = false
}

resource "auth0_client" "agent" {
  name                = local.client_name
  app_type            = local.app_type
  callbacks           = [local.callback_uri]
  grant_types         = local.grant_types
  allowed_logout_urls = [local.logout_url]
  oidc_conformant     = true

  jwt_configuration {
    alg = local.jwt_alg
  }
}

resource "auth0_client_credentials" "agent" {
  client_id     = auth0_client.agent.id
  client_secret = random_string.client_secret.result
}

resource "auth0_connection" "agent" {
  name     = local.connection_name
  strategy = "auth0"
  options {
    disable_signup = true
  }
}

resource "auth0_connection_clients" "agent" {
  connection_id   = auth0_connection.agent.id
  enabled_clients = [auth0_client.agent.id, var.auth0_management_client_id]
}

resource "auth0_user" "alice" {
  connection_name = auth0_connection.agent.name
  user_id         = "alice"
  nickname        = "Alice"
  email           = "alice@example.com"
  password        = local.user_password
  verify_email    = false
  depends_on      = [auth0_connection_clients.agent]
}

resource "auth0_user" "bob" {
  connection_name = auth0_connection.agent.name
  user_id         = "bob"
  nickname        = "Bob"
  email           = "bob@example.com"
  password        = local.user_password
  verify_email    = false
  depends_on      = [auth0_connection_clients.agent]
}

resource "auth0_resource_server" "agent" {
  name           = local.resource_server_name
  identifier     = local.resource_server_identifier
  signing_alg    = local.jwt_alg
  token_lifetime = 3600
  token_encryption {
    disable = true
  }
}

output "client_id" {
  value = auth0_client.agent.client_id
}

output "client_secret" {
  value = random_string.client_secret.result
}

output "connection_name" {
    value = local.connection_name
}

output "resource_server_identifier" {
  value = auth0_resource_server.agent.identifier
}

output "well_known_url" {
  value = "https://${var.auth0_domain}/.well-known/openid-configuration"
}

output "jwks_url" {
  value = "https://${var.auth0_domain}/.well-known/jwks.json"
}

output "sign_in_url" {
  value = "https://${var.auth0_domain}/authorize?client_id=${auth0_client.agent.client_id}&response_type=code&scope=openid%20profile%20email&redirect_uri=${local.callback_uri}"
}

output "logout_url" {
  value = "https://${var.auth0_domain}/v2/logout?client_id=${auth0_client.agent.client_id}&returnTo=${local.logout_url}"
}
