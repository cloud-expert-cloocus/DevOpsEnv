# ==================================================================
#  ResourceGroup
# ==================================================================

variable "network_resource_group" {
  type    = string
  default = "thira-comm-koce-network-rg"
}

variable "mes_resource_group" {
  type    = string
  default = "thira-prd-koce-mes-rg"
}

variable "azure_region" {
  type    = string
  default = "koreacentral"
}


# ==================================================================
#  Key Vault
# ==================================================================

variable "keyvault_resource_group" {
  type    = string
  default = "thira-comm-koce-rsg"
}
variable "keyvault_name" {
  type    = string
  default = "thira-comm-koce-kvlt-001"
}


# ==================================================================
#  Network
# ==================================================================

# prd
variable "prd_vnet_name" {
  type    = string
  default = "thira-prd-koce-vnet"
}

variable "prd_mes_snet_name" {
  type    = string
  default = "thira-prd-koce-mes-snet"
}


# ==================================================================
#  Container Registry
# ==================================================================

variable "acr_name" {
  type    = string
  default = "thiracommacr001"
}


# ==================================================================
#  Azure Kubernetes Cluster
# ==================================================================

# prd
variable "cluster_name" {
  type    = string
  default = "thira-prd-koce-mes-cluster"
}

variable "dns_name" {
  type    = string
  default = "thira-prd-001-dns"
}

variable "node_rg" {
  type    = string
  default = "thira-prd-koce-mes-nrg"
}

# comm
variable "admin_username" {
  type    = string
  default = "thiraadmin"
}

variable "kubernetes_version" {
  type    = string
  default = "1.21.9"
}

variable "agent_pools" {
  default = [
    {
      name            = "system"
      count           = 2
      vm_size         = "Standard_D1_v2"
      os_type         = "Linux"
      os_disk_size_gb = "20"
    }
  ]
}


# ==================================================================
#  Log Analytics
# ==================================================================

variable "log_analytics_workspace_name" {
  default = "thira-prd-koce-lga"
}

variable "log_analytics_workspace_location" {
  default = "koreacentral"
}