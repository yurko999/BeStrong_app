resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  workspace_id = azurerm_log_analytics_workspace.main.id

  application_type = "web"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}