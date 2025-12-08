resource "azurerm_storage_account" "premium_sa" {
  name                              = "wwwpremiumsa${random_string.premium_sa_suffix.result}"
  resource_group_name               = var.rgname
  location                          = var.loca
  account_tier                      = "Premium"
  account_replication_type          = "LRS"
  account_kind                      = "BlockBlobStorage"
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
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
    performance = "premium"
  }
}
resource "random_string" "premium_sa_suffix" {
  length  = 6
  special = false
  upper   = false
}
