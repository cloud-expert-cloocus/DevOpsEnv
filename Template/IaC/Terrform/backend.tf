terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "thira-comm-koce-rsg"
    storage_account_name = "thirastga001"
    container_name       = "tfstate"
    key                  = "key-001.tfstate"
  }
}