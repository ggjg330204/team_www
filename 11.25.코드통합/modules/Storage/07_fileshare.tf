resource "azurerm_storage_share" "share" {
  name               = "www-share"
  storage_account_id = azurerm_storage_account.www_sa.id
  quota              = 50
}
