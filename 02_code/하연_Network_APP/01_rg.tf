#source\01_rg.tf
resource "azurerm_resource_group" "www_rg" {
  name     = "04-T1-www"
  location = "KoreaCentral"
}
