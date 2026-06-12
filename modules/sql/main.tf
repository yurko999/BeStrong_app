resource "azurerm_mssql_server" "main" {
  name                = "sql-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  version = "12.0"

  azuread_administrator {
    login_username              = var.sql_aad_admin_login
    object_id                   = var.sql_aad_admin_object_id
    azuread_authentication_only = true

  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  public_network_access_enabled = false

}

resource "azurerm_mssql_database" "main" {
  name      = "sqldb-${var.project_name}-${var.environment}"
  server_id = azurerm_mssql_server.main.id

  sku_name = "Basic"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}