output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "container_app_subnet_id" {
  value = azurerm_subnet.container_app.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}