#source\01_rg.tf
resource "azurerm_resource_group" "www_rg" {
  name     = var.rg_name
  location = var.loca
}
