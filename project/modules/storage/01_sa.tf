# 1. Storage Account
resource "azurerm_storage_account" "www_sa" {
  name                     = var.sa_name
  resource_group_name      = var.rgname
  location                 = var.loca
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "production"
    team        = "www"
  }
}
