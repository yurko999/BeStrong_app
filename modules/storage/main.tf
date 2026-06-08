resource "azurerm_storage_account" "main" {
  name                = "st${var.project_name}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "azurerm_storage_share" "files" {
  name               = "uploads"
  storage_account_id = azurerm_storage_account.main.id

  quota = 50
}