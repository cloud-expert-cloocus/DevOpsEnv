# 생성할 리소스들에 대해 정의합니다.

//==================================================================
// Resource Group
//==================================================================
resource "azurerm_resource_group" "sample_rg" {
  name     = var.sample_rg
  location = var.location
}


//==================================================================
// Network
//==================================================================
resource "azurerm_virtual_network" "sample_vnet" {
  name                = var.sample_vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sample_rg.location
  resource_group_name = azurerm_resource_group.sample_rg.name
}

resource "azurerm_subnet" "sample_snet_001" {
  name                 = var.sample_snet_001
  resource_group_name  = azurerm_resource_group.sample_rg.name
  virtual_network_name = azurerm_virtual_network.sample_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}


//==================================================================
// WepApp
//==================================================================
resource "azurerm_app_service_plan" "sample_plan" {
  name                = var.sample_plan
  location            = azurerm_resource_group.sample_rg.location
  resource_group_name = azurerm_resource_group.sample_rg.name
  // Define Linux as Host OS
  kind     = "Linux"
  reserved = true

  // Choose size
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "sample_webapp" {
  name                = var.sample_webapp
  location            = azurerm_resource_group.sample_rg.location
  resource_group_name = azurerm_resource_group.sample_rg.name
  app_service_plan_id = azurerm_app_service_plan.sample_plan.id
}


//==================================================================
// Cosmos DB
//==================================================================
resource "azurerm_resource_group" "sample_db_rg" {
  name     = var.sample_db_rg
  location = var.location
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "sample_cosmosdb_acc" {
  name                      = var.sample_cosmosdb_acc
  location                  = azurerm_resource_group.sample_db_rg.location
  resource_group_name       = azurerm_resource_group.sample_db_rg.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  
  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "Session"
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }
  geo_location {
    location          = azurerm_resource_group.sample_rg.location
    failover_priority = 0
  }
}
