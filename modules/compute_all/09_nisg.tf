#modules\vm.tf\09_nisg.tf
resource "azurerm_network_interface_security_group_association" "www_bassg" {
    network_interface_id = azurerm_network_interface.www_bas_nic.id
    network_security_group_id = azurerm_network_security_group.www_nsg_ssh.id
}

resource "azurerm_network_interface_security_group_association" "www_web1sg" {
    network_interface_id = azurerm_network_interface.www_web1_nic.id
    network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_network_interface_security_group_association" "www_dbsg" {
    network_interface_id = azurerm_network_interface.www_db_nic.id
    network_security_group_id = azurerm_network_security_group.www_nsg_db.id
}