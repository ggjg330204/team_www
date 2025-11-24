#project\modules\Security\02_vnet.tf
resource "azurerm_virtual_network" "hj_vnet" {
  name                = "${var.teamuser}-vnet"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name
  address_space       = ["10.0.0.0/16"]
}