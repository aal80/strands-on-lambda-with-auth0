locals {
  fn_architecture      = "arm64"
  jwt_signature_secret = "jwt-signature-secret"
}

module "auth0" {
  source                     = "./modules/auth0"
  auth0_domain               = var.auth0_domain
  auth0_management_client_id = var.auth0_management_client_id
}

module "mcp_server" {
  source               = "./modules/mcp-server"
  fn_architecture      = local.fn_architecture
  jwt_signature_secret = local.jwt_signature_secret
  depends_on = [ module.auth0 ]
}

module "agent_dependencies" {
  source = "./modules/agent-dependencies"
  depends_on = [ module.auth0 ]
}

module "agent" {
  source                           = "./modules/agent"
  fn_architecture                  = local.fn_architecture
  fn_dependecies_layer_arn         = module.agent_dependencies.dependencies_layer_arn
  jwt_signature_secret             = local.jwt_signature_secret
  auth0_jwks_url                   = module.auth0.jwks_url
  auth0_resource_server_identifier = module.auth0.resource_server_identifier
  mcp_endpoint                     = module.mcp_server.mcp_endpoint
  depends_on = [ module.agent_dependencies ]
}


output "outputs_map" {
  value = tomap({
    auth0_client_id : module.auth0.client_id,
    auth0_client_secret : module.auth0.client_secret,
    auth0_connection_name: module.auth0.connection_name,
    auth0_well_known_url : module.auth0.well_known_url,
    auth0_jwks_url : module.auth0.jwks_url,
    auth0_sign_in_url : module.auth0.sign_in_url,
    auth0_logout_url : module.auth0.logout_url
    auth0_resource_server_identifier : module.auth0.resource_server_identifier
    mcp_endpoint : module.mcp_server.mcp_endpoint,
    agent_endpoint : module.agent.agent_endpoint
  })
  sensitive = true
}


