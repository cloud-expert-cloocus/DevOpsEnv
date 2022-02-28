# ==================================================================
#  ResourceGroup
# ==================================================================

resource "azurerm_resource_group" "comm_network_rg" {
  name     = var.network_comm_resource_group
  location = var.azure_region
}

resource "azurerm_resource_group" "prd_mes_rg" {
  name     = var.mes_prd_resource_group
  location = var.azure_region
}

resource "azurerm_resource_group" "stg_mes_rg" {
  name     = var.mes_stg_resource_group
  location = var.azure_region
}

resource "azurerm_resource_group" "comm_rsg" {
  name     = var.resource_security_group
  location = var.azure_region
}


# ==================================================================
#  Virtual Network
# ==================================================================

resource "azurerm_virtual_network" "comm_vnet" {
  name                = var.comm_vnet_name
  resource_group_name = azurerm_resource_group.comm_network_rg.name
  location            = azurerm_resource_group.comm_network_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "agw_snet" {
  name                 = var.comm_agw_snet_name
  resource_group_name  = azurerm_resource_group.comm_network_rg.name
  virtual_network_name = azurerm_virtual_network.comm_vnet.name
  address_prefix       = "10.0.1.0/26"
}

resource "azurerm_subnet" "vgw_snet" {
  name                 = var.comm_vgw_snet_name
  resource_group_name  = azurerm_resource_group.comm_network_rg.name
  virtual_network_name = azurerm_virtual_network.comm_vnet.name
  address_prefix       = "10.0.2.0/26"
}

resource "azurerm_virtual_network" "prd_vnet" {
  name                = var.prd_vnet_name
  resource_group_name = azurerm_resource_group.comm_network_rg.name
  location            = azurerm_resource_group.comm_network_rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "prd_mes_snet" {
  name                 = var.prd_mes_snet_name
  resource_group_name  = azurerm_resource_group.comm_network_rg.name
  virtual_network_name = azurerm_virtual_network.prd_vnet.name
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_virtual_network" "stg_vnet" {
  name                = var.stg_vnet_name
  resource_group_name = azurerm_resource_group.comm_network_rg.name
  location            = azurerm_resource_group.comm_network_rg.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "stg_mes_snet" {
  name                 = var.stg_mes_snet_name
  resource_group_name  = azurerm_resource_group.comm_network_rg.name
  virtual_network_name = azurerm_virtual_network.stg_vnet.name
  address_prefix       = "10.2.1.0/24"
}


# ==================================================================
#  VPN Gateway
# ==================================================================

resource "azurerm_public_ip" "comm-vgw-pip-001" {
  name                = "thira-comm-pip-001"
  location            = azurerm_resource_group.comm_network_rg.location
  resource_group_name = azurerm_resource_group.comm_network_rg.location

  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "comm-vgw" {
  name                = "thira-comm-koce-vgw"
  location            = azurerm_resource_group.comm_network_rg.location
  resource_group_name = azurerm_resource_group.comm_network_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1AZ"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.comm-vgw-pip-001.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vgw_snet.id
  }
}


# ==================================================================
#  Storage Account
# ==================================================================

resource "azurerm_storage_account" "comm_stga" {
  name                     = "thirastga001"
  resource_group_name      = "thira-comm-rsg"
  location                 = var.azure_region
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
}

resource "azurerm_storage_container" "comm_registry" {
  name                  = "tfstate"
  storage_account_name  = "thirastga001"
  container_access_type = "private"
}


# ==================================================================
#  AKS Cluster - prd
# ==================================================================

resource "azurerm_kubernetes_cluster" "prd_aks_cluster" {
  name                = var.prd_cluster_name
  location            = azurerm_resource_group.prd_mes_rg.location
  resource_group_name = azurerm_resource_group.prd_mes_rg.name
  dns_prefix          = var.prd_dns_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = var.prd_node_rg

  default_node_pool {
    name                = "messervie"
    mode                = "System"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
    os_type             = "Linux"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    node_labels         = { 
      "nodetype" : "master"
    }
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "172.16.0.0/16"
  }

  role_based_access_control {
    enabled = true
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.client-id.value
    client_secret = data.azurerm_key_vault_secret.client-secret.value
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "prd_aks_nodepool" {
  name                  = "mesworker"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.prd_aks_cluster.id
  mode                  = "User"
  vm_size               = "Standard_DS2_v2"
  enable_auto_scaling   = true
  max_count             = 3
  min_count             = 1
  os_type               = "Linux"
  os_disk_size_gb       = 30
  type                  = "VirtualMachineScaleSets"
  node_labels           = { 
    "nodetype" : "worker"
    "servicetype" : "cpu"
  }
}


# ==================================================================
#  AKS Cluster - stg
# ==================================================================

resource "azurerm_kubernetes_cluster" "stg_aks_cluster" {
  name                = var.stg_cluster_name
  location            = azurerm_resource_group.stg_mes_rg.location
  resource_group_name = azurerm_resource_group.stg_mes_rg.name
  dns_prefix          = var.stg_dns_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = var.stg_node_rg

  default_node_pool {
    name                = "stg-messervie"
    mode                = "System"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
    os_type             = "Linux"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    node_labels         = { 
      "nodetype" : "master"
    }
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "172.17.0.10"
    docker_bridge_cidr = "172.18.0.1/16"
    service_cidr       = "172.17.0.0/16"
  }

  role_based_access_control {
    enabled = true
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.client-id.value
    client_secret = data.azurerm_key_vault_secret.client-secret.value
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "stg_aks_nodepool" {
  name                  = "stg-mesworker"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.stg_aks_cluster.id
  mode                  = "User"
  vm_size               = "Standard_DS2_v2"
  enable_auto_scaling   = true
  max_count             = 3
  min_count             = 1
  os_type               = "Linux"
  os_disk_size_gb       = 30
  type                  = "VirtualMachineScaleSets"
  node_labels           = { 
    "nodetype" : "worker"
    "servicetype" : "cpu"
  }
}


# ==================================================================
#  Azure Container Registry(ACR)
# ==================================================================

resource "azurerm_container_registry" "comm_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.prd_mes_rg.name
  location            = var.azure_region
  sku                 = "Premium"
  admin_enabled       = false
  depends_on          = [azurerm_resource_group.prd_mes_rg]
}

# Assign AcrPull role to service principal
resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                            = azurerm_container_registry.comm_acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = data.azurerm_key_vault_secret.client-id.value
  skip_service_principal_aad_check = true
}


# ==================================================================
#  Log Analytics
# ==================================================================

resource "azurerm_log_analytics_workspace" "loga" {
  name                = var.log_analytics_workspace_name
  location            = var.log_analytics_workspace_location
  resource_group_name = azurerm_resource_group.prd_mes_rg.name
}

resource "azurerm_log_analytics_solution" "loga" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.loga.location
  resource_group_name   = azurerm_resource_group.prd_mes_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.loga.id
  workspace_name        = azurerm_log_analytics_workspace.loga.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


