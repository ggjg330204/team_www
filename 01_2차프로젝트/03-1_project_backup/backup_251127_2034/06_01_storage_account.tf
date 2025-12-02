resource "azurerm_storage_account" "www_sa" {
  name                     = "wwwstore${var.teamuser}004"
  resource_group_name      = azurerm_resource_group.www_rg.name
  location                 = azurerm_resource_group.www_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["61.108.60.26"]
    virtual_network_subnet_ids = [azurerm_subnet.www_db.id]
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
