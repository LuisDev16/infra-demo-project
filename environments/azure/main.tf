module "network" {
  source                  = "git::https://github.com/LuisDev16/modulos-terraform.git//azure/network?ref=main"
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  address_space           = var.address_space
  subnet_name             = var.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-lab"
    storage_account_name = "saluisdev01"
    container_name       = "tfstate"
    key                  = "infra-demo-project.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

# BEGIN ISSUE COPILOT: 1
module "network_issue_1" {
  source                  = "git::https://github.com/LuisDev16/modulos-terraform.git//azure/network?ref=fa2a8482436be6938c90f34846d77181bdc64c7d"
  name                    = "vnet-dev-01"
  resource_group_name     = "rg-dev-01"
  location                = "eastus"
  address_space           = ["10.20.0.0/16"]
  subnet_name             = "subnet-dev-01"
  subnet_address_prefixes = ["10.20.1.0/24"]
  vm_enabled              = false
  tags                    = { "Environment" = "dev", "ManagedBy" = "infra-demo-issue-copilot", "RequestIssue" = "1" }
}
# END ISSUE COPILOT: 1
