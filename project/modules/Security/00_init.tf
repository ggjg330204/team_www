#project\modules\Security\00_init.tf
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=4.54.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subid
  features {}
}