# Terraform Cloud에 Remote 백엔드로 설정하였습니다.

terraform {
  backend "remote" {
    organization = "sample-organization"

    workspaces {
      name = "sample-workspace"
    }
  }
}

provider "azurerm" {
  version = "~>2.0"

  features {}
}