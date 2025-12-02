resource "azurerm_network_interface_backend_address_pool_association" "www_lbback1_v1" {
  network_interface_id    = azurerm_network_interface.www_web1_v1_nic.id
  ip_configuration_name   = "www-web1-v1-nic-ipconf"
  backend_address_pool_id = azurerm_lb_backend_address_pool.www_back_v1.id

}

resource "azurerm_network_interface_backend_address_pool_association" "www_lbback2_v1" {
  network_interface_id    = azurerm_network_interface.www_web2_v1_nic.id
  ip_configuration_name   = "www-web2-v1-nic-ipconf"
  backend_address_pool_id = azurerm_lb_backend_address_pool.www_back_v1.id

}