terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}

provider "azuread" {
  tenant_id = "548e9ef4-b1d5-48fa-b220-59f52d6db511"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "azurerm_resource_group" "rg" {
  name     = "04-t1-www-rg"
  location = "Korea Central"
  tags = {
    Environment = "Production"
    Purpose     = "Main-Resource-Group"
    ManagedBy   = "Terraform"
  }
}