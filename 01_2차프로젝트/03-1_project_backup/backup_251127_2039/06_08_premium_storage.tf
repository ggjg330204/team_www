resource "azurerm_storage_account" "premium_sa" {
  name                     = "wwwpremiumsa${random_string.sa_suffix.result}"
  resource_group_name      = azurerm_resource_group.www_rg.name
  location                 = var.loca
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "BlockBlobStorage"
}

resource "random_string" "sa_suffix" {
  length  = 6
  special = false
  upper   = false
}
