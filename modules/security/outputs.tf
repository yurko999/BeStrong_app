output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "sql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql.id
}

output "keyvault_private_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault.id
}

output "storage_private_dns_zone_id" {
  value = azurerm_private_dns_zone.storage.id
}