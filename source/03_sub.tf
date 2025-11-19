resource "azurerm_subnet" "www_bas" {
  name                            = "www-bas"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = false
}