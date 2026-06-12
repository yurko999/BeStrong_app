module "resource_group" {
  source = "./modules/resource_group"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name
}

module "acr" {
  source = "./modules/acr"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name
}

module "sql" {
  source = "./modules/sql"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name

  sql_aad_admin_login     = var.sql_aad_admin_login
  sql_aad_admin_object_id = var.sql_aad_admin_object_id

}

module "container_app" {
  source = "./modules/container_app"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  container_app_subnet_id = module.network.container_app_subnet_id
  
  acr_login_server = module.acr.login_server
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name

  vnet_id = module.network.vnet_id

  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id

  storage_account_id = module.storage.storage_account_id

  sql_server_id = module.sql.sql_server_id

  acr_id = module.acr.id

  managed_identity_principal_id = module.container_app.managed_identity_principal_id

  runner_ip = var.runner_ip

}

module "private_endpoints" {
  source = "./modules/private_endpoints"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_name = module.resource_group.name

  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id

  sql_server_id      = module.sql.sql_server_id
  storage_account_id = module.storage.storage_account_id
  key_vault_id       = module.security.key_vault_id

  sql_private_dns_zone_id      = module.security.sql_private_dns_zone_id
  storage_private_dns_zone_id  = module.security.storage_private_dns_zone_id
  keyvault_private_dns_zone_id = module.security.keyvault_private_dns_zone_id
}