output "sql_private_endpoint_id" {
  value = azurerm_private_endpoint.sql.id
}

output "storage_private_endpoint_id" {
  value = azurerm_private_endpoint.storage.id
}

output "keyvault_private_endpoint_id" {
  value = azurerm_private_endpoint.keyvault.id
}