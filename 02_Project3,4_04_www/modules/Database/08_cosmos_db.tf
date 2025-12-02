resource "azurerm_cosmosdb_account" "cosmos" {
  name                                  = "www-cosmos-${random_string.cosmos_suffix.result}"
  location                              = var.loca
  resource_group_name                   = var.rgname
  offer_type                            = "Standard"
  kind                                  = "GlobalDocumentDB"
  automatic_failover_enabled            = true
  public_network_access_enabled         = true
  local_authentication_disabled         = false
  access_key_metadata_writes_enabled    = true
  network_acl_bypass_for_azure_services = true
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    location          = var.loca
    failover_priority = 0
    zone_redundant    = true
  }
  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 720
    storage_redundancy  = "Geo"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Cosmos-DB"
    ManagedBy   = "Terraform"
  }
}
resource "random_string" "cosmos_suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "www-sql-db"
  resource_group_name = var.rgname
  account_name        = azurerm_cosmosdb_account.cosmos.name
}
resource "azurerm_cosmosdb_sql_container" "example" {
  name                = "Items"
  resource_group_name = var.rgname
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/definition/id"]
  autoscale_settings {
    max_throughput = 4000
  }
  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
    excluded_path {
      path = "/_etag/?"
    }
    composite_index {
      index {
        path  = "/createdAt"
        order = "ascending"
      }
      index {
        path  = "/status"
        order = "ascending"
      }
    }
    spatial_index {
      path = "/location/*"
    }
  }
  unique_key {
    paths = ["/email"]
  }
  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }
  default_ttl = -1
}