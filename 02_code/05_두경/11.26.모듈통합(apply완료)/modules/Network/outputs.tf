output "vnet0_id" {
  value = azurerm_virtual_network.www_vnet0.id
}

output "sub_bas_id" {
  value = azurerm_subnet.www_bas.id
}

output "sub_web1_id" {
  value = azurerm_subnet.www_web1.id
}

output "sub_web2_id" {
  value = azurerm_subnet.www_web2.id
}

output "sub_db_id" {
  value = azurerm_subnet.www_db.id
}

output "sub_vmss_id" {
  value = azurerm_subnet.www_vmss.id
}

output "sub_web1_v1_id" {
  value = azurerm_subnet.www_web1_v1.id
}

output "pub_bas_id" {
  value = azurerm_public_ip.www_basip.id
}

output "appgw_be_pool_id" {
  value = tolist(azurerm_application_gateway.www_appgw.backend_address_pool)[0].id
}

output "nic_bas_id" {
  value = azurerm_network_interface.www_bas_nic.id
}

output "nic_web1_id" {
  value = azurerm_network_interface.www_web1_nic.id
}

output "nic_web2_id" {
  value = azurerm_network_interface.www_web2_nic.id
}

output "nic_db_id" {
  value = azurerm_network_interface.www_db_nic.id
}

output "nic_web1_v1_id" {
  value = azurerm_network_interface.www_web1_v1_nic.id
}

output "bas_pub_ip" {
  value = azurerm_public_ip.www_basip.ip_address
}
