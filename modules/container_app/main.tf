resource "azurerm_container_app_environment" "main" {
  name = "cae-${var.project_name}-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id   = var.container_app_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  internal_load_balancer_enabled = true // no public IP on the env

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app" "main" {
  name                         = "ca-${var.project_name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }
  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  template {
    container {
      name   = "backend"
      image  = "nginx:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = true

    target_port = 80

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}