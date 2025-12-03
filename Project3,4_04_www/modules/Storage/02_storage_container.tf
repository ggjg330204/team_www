resource "azurerm_storage_container" "www_media" {
  name                  = "media"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
  metadata = {
    purpose     = "User uploaded media files (photos, videos)"
    retention   = "long-term"
    criticality = "high"
  }
}
resource "azurerm_storage_container" "www_tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
  metadata = {
    purpose     = "Terraform state files"
    retention   = "permanent"
    criticality = "critical"
  }
}
resource "azurerm_storage_container" "www_container" {
  name                  = "www-files"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
  metadata = {
    purpose     = "General application files"
    retention   = "medium-term"
    criticality = "medium"
  }
}
resource "azurerm_storage_container" "wordpress_content" {
  name                  = "wordpress-content"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
  metadata = {
    purpose     = "WordPress content and uploads"
    retention   = "long-term"
    criticality = "high"
  }
}
resource "azurerm_storage_container" "mysql_backups" {
  name                  = "mysql-backups"
  storage_account_id    = azurerm_storage_account.www_sa.id
  container_access_type = "private"
  metadata = {
    purpose     = "MySQL database backups"
    retention   = "compliance"
    criticality = "critical"
  }
}
