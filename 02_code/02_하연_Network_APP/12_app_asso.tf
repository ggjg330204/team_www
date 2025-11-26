resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "www_web1_v1_nic" {
  network_interface_id    = azurerm_network_interface.www_web1_v1_nic.id
  ip_configuration_name   = "www-web1-v1-nic-ipconf"
  backend_address_pool_id = tolist(azurerm_application_gateway.www_appgw.backend_address_pool)[0].id
  depends_on = [azurerm_network_interface.www_web1_v1_nic]
}  

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "www_web2_v1_nic" {
  network_interface_id    = azurerm_network_interface.www_web2_v1_nic.id
  ip_configuration_name   = "www-web2-v1-nic-ipconf"
  backend_address_pool_id = tolist(azurerm_application_gateway.www_appgw.backend_address_pool)[0].id
  depends_on = [azurerm_network_interface.www_web2_v1_nic]
}