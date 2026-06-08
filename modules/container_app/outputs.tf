output "container_app_id" {
  value = azurerm_container_app.main.id
}

output "container_app_name" {
  value = azurerm_container_app.main.name
}

output "container_app_url" {
  value = azurerm_container_app.main.latest_revision_fqdn
}

output "managed_identity_principal_id" {
  value = azurerm_container_app.main.identity[0].principal_id
}