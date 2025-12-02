resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_storage_account" "function" {
  name                     = "wwwfuncsa${random_string.suffix.result}"
  resource_group_name      = var.rgname
  location                 = var.loca
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
  tags = {
    Environment = "Production"
    Purpose     = "Function-Storage"
    ManagedBy   = "Terraform"
  }
}
