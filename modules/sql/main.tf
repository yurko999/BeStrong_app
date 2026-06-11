resource "azurerm_mssql_server" "main" {
  name                = "sql-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  version = "12.0"

  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

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