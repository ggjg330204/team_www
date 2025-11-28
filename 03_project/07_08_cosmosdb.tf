resource "azurerm_cosmosdb_account" "cosmos" {
  name                       = "www-cosmos-${random_string.cosmos_suffix.result}"
  location                   = var.loca
  resource_group_name        = azurerm_resource_group.www_rg.name
  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  automatic_failover_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.loca
    failover_priority = 0
  }

  geo_location {
    location          = var.loca2
    failover_priority = 1
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 1440
    retention_in_hours  = 8
  }
}

resource "random_string" "cosmos_suffix" {
  length  = 6
  special = false
  upper   = false
}
