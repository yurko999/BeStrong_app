#sql private endpoint
resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = var.sql_server_id

    subresource_names = ["sqlServer"]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "sql-dns-zone-group"

    private_dns_zone_ids = [
      var.sql_private_dns_zone_id
    ]
  }
}
#storage private endpoint
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = var.storage_account_id

    subresource_names = ["file"]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "storage-dns-zone-group"

    private_dns_zone_ids = [
      var.storage_private_dns_zone_id
    ]
  }
}
#keyvault private endpoint
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-keyvault-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = var.key_vault_id

    subresource_names = ["vault"]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "keyvault-dns-zone-group"

    private_dns_zone_ids = [
      var.keyvault_private_dns_zone_id
    ]
  }
}