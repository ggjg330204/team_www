#project\modules\Security\01_rg.tf
resource "azurerm_resource_group" "www_rg" {
  name     = var.rgname
  location = var.loca
}