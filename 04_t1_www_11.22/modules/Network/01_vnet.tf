resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.loca
  resource_group_name = var.rgname
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}
