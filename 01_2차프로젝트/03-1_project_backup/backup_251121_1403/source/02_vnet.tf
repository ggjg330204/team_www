#source\02_vnet.tf
resource "azurerm_virtual_network" "www_vnet" {
  name                = "${var.teamuser}-vnet"
  location            = var.loca
  resource_group_name = var.rgname
  address_space       = ["10.0.0.0/16"]
  }
