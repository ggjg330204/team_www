
resource "azurerm_virtual_network_peering" "peer_ctr_sth" {
  name                      = "ctr-sth"
  resource_group_name       = var.rgname
  virtual_network_name      = azurerm_virtual_network.www_vnet0.name
  remote_virtual_network_id = azurerm_virtual_network.www_vnet1.id
}

resource "azurerm_virtual_network_peering" "peer_sth_ctr" {
  name                      = "sth-ctr"
  resource_group_name       = var.rgname
  virtual_network_name      = azurerm_virtual_network.www_vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.www_vnet0.id
}