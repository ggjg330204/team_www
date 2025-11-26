# 2. Storage Containers
resource "azurerm_storage_container" "www_media" {
  name                  = "media"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "www_tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
}
