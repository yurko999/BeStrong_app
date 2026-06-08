resource "random_password" "sql_admin" {
  length  = 24
  special = true

  override_special = "!@#$%^&*"
}

resource "azurerm_key_vault" "main" {
  name = "kv-${var.project_name}-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  public_network_access_enabled = true

  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "current_user_admin" {
  scope = azurerm_key_vault.main.id

  role_definition_name = "Key Vault Administrator"

  principal_id = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}



resource "azurerm_key_vault_secret" "sql_admin_password" {
  depends_on = [
    azurerm_role_assignment.current_user_admin
  ]

  name         = "sql-admin-password"
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "storage-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope = var.acr_id

  role_definition_name = "AcrPull"

  principal_id = var.managed_identity_principal_id
}
resource "azurerm_role_assignment" "keyvault_secrets_user" {
  scope = azurerm_key_vault.main.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = var.managed_identity_principal_id
}

