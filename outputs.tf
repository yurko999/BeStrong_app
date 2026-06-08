output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_id" {
  value = module.resource_group.id
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "container_app_subnet_id" {
  value = module.network.container_app_subnet_id
}

output "private_endpoint_subnet_id" {
  value = module.network.private_endpoint_subnet_id
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "sql_server_fqdn" {
  value = module.sql.sql_server_fqdn
}

output "container_app_url" {
  value = module.container_app.container_app_url
}

output "managed_identity_principal_id" {
  value = module.container_app.managed_identity_principal_id
}