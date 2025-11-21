#source\03_sub.tf
resource "azurerm_subnet" "www_bas" {
  name                            = "${var.teamuser}-bas"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-bas
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = false
}