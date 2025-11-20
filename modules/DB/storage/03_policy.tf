# 3. Lifecycle Management Policy
resource "azurerm_storage_management_policy" "www_policy" {
  storage_account_id = azurerm_storage_account.www_sa.id

  rule {
    name    = "cleanup-old-files"
    enabled = true
    filters {
      prefix_match = ["media/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
}
