terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateyurko01"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }
}