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

resource "azurerm_storage_container" "www_container" {
  name                  = "www-files"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "wordpress_content" {
  name                  = "wordpress-content"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "blob"
}

resource "azurerm_storage_container" "mysql_backups" {
  name                  = "mysql-backups"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
}
