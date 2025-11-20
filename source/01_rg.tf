#source\01_rg.tf
resource "azurerm_resource_group" "www_rg" {
  name     = "04-ghlee"
  location = "Korea Central"
}
