resource "azurerm_storage_account" "www_sa" {
  name                     = var.sa_name
  resource_group_name      = var.rgname
  location                 = var.loca
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Private Endpoint없으면 주석처리 해야함
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["61.108.60.26"]
    virtual_network_subnet_ids = [var.storage_subnet_id]
    bypass                     = ["AzureServices"]
  }

  tags = {
    environment = "production"
    team        = "www"
  }

  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
    
    container_delete_retention_policy {
      days = 7
    }
  }
}
