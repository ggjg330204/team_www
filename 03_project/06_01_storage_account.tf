resource "azurerm_storage_account" "www_sa" {
  name                     = "wwwstorage${random_string.sa_suffix.result}"
  resource_group_name      = azurerm_resource_group.www_rg.name
  location                 = azurerm_resource_group.www_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = true
  shared_access_key_enabled         = true
  infrastructure_encryption_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["61.108.60.26"]
    virtual_network_subnet_ids = [azurerm_subnet.www_db.id]
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 7
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }

    restore_policy {
      days = 29
    }

    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}
