resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["10.0.0.0/16"]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "azurerm_subnet" "container_app" {
  name                 = "snet-container-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["10.0.1.0/24"]

  delegation {
    name = "container-apps"

    service_delegation {
      name = "Microsoft.App/environments"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["10.0.2.0/24"]
}