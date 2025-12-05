terraform {
  backend "azurerm" {
    resource_group_name  = "04-t1-www-rg"
    storage_account_name = "wwwstoragecphr"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
