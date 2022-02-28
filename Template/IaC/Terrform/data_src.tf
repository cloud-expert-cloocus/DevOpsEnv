data "azurerm_key_vault" "terraform_vault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resource_group
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "LinuxSSHPubKey"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "client-id" {
  name         = "client-id"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "client-secret" {
  name         = "client-secret"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "tenant-id" {
  name         = "tenant-id"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "subscription_id" {
  name         = "subscription-id"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_key_vault_secret" "access-key" {
  name         = "access-key"
  key_vault_id = data.azurerm_key_vault.terraform_vault.id
}

data "azurerm_client_config" "current" {}