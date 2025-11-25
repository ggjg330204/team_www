resource "azurerm_virtual_network" "www_vnet0" {
  name                = "${var.teamuser}-vnet0"
  location            = var.loca
  resource_group_name = var.rgname
  address_space       = ["10.0.0.0/16"]
  }

resource "azurerm_virtual_network" "www_vnet1" {
  name                = "${var.teamuser}-vnet1"
  location            = "KoreaSouth"
  resource_group_name = var.rgname
  address_space       = ["192.168.0.0/16"]
  }