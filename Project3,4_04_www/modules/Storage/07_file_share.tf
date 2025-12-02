resource "azurerm_storage_share" "share" {
  name               = "www-share"
  storage_account_id = azurerm_storage_account.www_sa.id
  quota              = 100
  enabled_protocol   = "SMB"
  access_tier        = "Hot"
  acl {
    id = "www-share-access"
    access_policy {
      permissions = "rwdl"
      start       = timeadd(timestamp(), "-1h")
      expiry      = timeadd(timestamp(), "8760h")
    }
  }
}
