resource "azurerm_storage_share" "share" {
  name               = "www-share"
  storage_account_id = azurerm_storage_account.www_sa.id
  quota              = 100
  enabled_protocol   = "SMB"
  access_tier        = "Hot"

  metadata = {
    environment = "production"
    purpose     = "shared-files"
    team        = "www"
  }

  acl {
    id = "www-share-policy"
    access_policy {
      permissions = "rwdl"
      start       = "2024-01-01T00:00:00Z"
      expiry      = "2025-12-31T23:59:59Z"
    }
  }
}
