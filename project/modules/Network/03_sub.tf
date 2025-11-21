#source\03_sub.tf
resource "azurerm_subnet" "www_bas" {
  name                            = "${var.teamuser}-bas"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = false
}
