resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = "Basic"
  admin_enabled = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}