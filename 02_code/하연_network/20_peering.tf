
resource "azurerm_virtual_network_peering" "peer_ctr_sth" {
  name                      = "ctr-sth"
  resource_group_name       = var.rgname
  virtual_network_name      = var.vnet0.name
  remote_virtual_network_id = var.vnet1.id
}

resource "azurerm_virtual_network_peering" "peer_sth_ctr" {
  name                      = "sth-ctr"
  resource_group_name       = var.rgname
  virtual_network_name      = var.vnet1.name
  remote_virtual_network_id = var.vnet0.id
}