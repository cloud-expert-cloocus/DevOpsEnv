# 변수 값을 선언하여, Azure 인프라에 리소스를 배포할 수 있습니다.

// basic variable
variable "sample_rg" {
  type    = string
  default = "sample-tst-devops-rg"
}

variable "sample_db_rg" {
  type    = string
  default = "sample-tst-devops-rg"
}

variable "location" {
  type    = string
  default = "koreacentral"
}

// network variable
variable "sample_vnet" {
  type    = string
  default = "sample-tst-vnet-001"
}

variable "sample_snet_001" {
  type    = string
  default = "sample-tst-snet-001"
}

// cosmos db variable
variable "sample_cosmosdb_acc" {
  type    = string
  default = "sample-tst-cosmosdb-acc"
}

variable "cosmos_db_account_name" {
  type    = string
  default = "sample-cosmos-db-001"
}

variable "failover_location" {
  type    = string
  default = "koreacentral"
}

// web app
variable "sample_plan" {
  type    = string
  default = "sample-tst-plan-001"
}

variable "sample_webapp" {
  type    = string
  default = "sample-tst-webapp-001"
}
