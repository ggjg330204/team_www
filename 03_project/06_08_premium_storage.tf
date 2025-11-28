resource "azurerm_storage_account" "premium_sa" {
  name                              = "wwwpremiumsa${random_string.sa_suffix.result}"
  resource_group_name               = azurerm_resource_group.www_rg.name
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
    ip_rules                   = ["61.108.60.26"]
    virtual_network_subnet_ids = [azurerm_subnet.www_db.id]
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }
}

resource "random_string" "sa_suffix" {
  length  = 4
  special = false
  upper   = false
}
