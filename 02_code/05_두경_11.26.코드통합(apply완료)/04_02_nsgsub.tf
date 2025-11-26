resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_bas" {
  subnet_id                 = azurerm_subnet.www_bas.id
  network_security_group_id = azurerm_network_security_group.www_nsg_ssh.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web1" {
  subnet_id                 = azurerm_subnet.www_web1.id
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web2" {
  subnet_id                 = azurerm_subnet.www_web2.id
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_db" {
  subnet_id                 = azurerm_subnet.www_db.id
  network_security_group_id = azurerm_network_security_group.www_nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_web1" {
  subnet_id                 = azurerm_subnet.www_web1_v1.id
  network_security_group_id = azurerm_network_security_group.www_v1_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_vmss" {
  subnet_id                 = azurerm_subnet.www_vmss.id
  network_security_group_id = azurerm_network_security_group.www_v1_nsg_http.id
}