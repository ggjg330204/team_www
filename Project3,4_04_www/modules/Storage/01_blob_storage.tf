resource "random_string" "sa_suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_storage_account" "www_sa" {
  name                              = "wwwstorage${random_string.sa_suffix.result}"
  resource_group_name               = var.rgname
  location                          = var.loca
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = true
  infrastructure_encryption_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = [var.storage_subnet_id]
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }

  tags = {
    environment = "production"
    team        = "www"
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
      allowed_origins    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}
