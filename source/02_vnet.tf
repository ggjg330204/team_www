#source\02_vnet.tf
resource "azurerm_virtual_network" "www_vnet" {
  name                = "www-vnet"
  location            = var.loca
  resource_group_name = azurerm_resource_group._rg.name
  address_space       = ["10.0.0.0/16"]
  }
