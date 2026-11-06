/*module "network" {
  source                  = "git::https://github.com/LuisDev16/modulos-terraform.git//azure/network?ref=main"
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  address_space           = var.address_space
  subnet_name             = var.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
}*/

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
