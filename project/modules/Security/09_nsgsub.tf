resource "azurerm_subnet_network_security_group_association" "hj_asso_subnsg_bas" {
  subnet_id                 = azurerm_subnet.hj_sub_bas.id
  network_security_group_id = azurerm_network_security_group.hj_nsg_ssh.id
}

resource "azurerm_subnet_network_security_group_association" "hj_asso_subnsg_web" {
  subnet_id                 = azurerm_subnet.hj_sub_web.id
  network_security_group_id = azurerm_network_security_group.hj_nsg_ssh_http.id
}

resource "azurerm_subnet_network_security_group_association" "hj_asso_subnsg_db" {
  subnet_id                 = azurerm_subnet.hj_sub_db.id
  network_security_group_id = azurerm_network_security_group.hj_nsg_ssh_db.id
}