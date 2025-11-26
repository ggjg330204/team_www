resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_bas" {
  subnet_id                 = var.bas_subnet_id
  network_security_group_id = azurerm_network_security_group.www_nsg_ssh.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web1" {
  subnet_id                 = var.web1_subnet_id
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web2" {
  subnet_id                 = var.web2_subnet_id
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_db" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.www_nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_web1" {
  subnet_id                 = var.web1_v1_subnet_id
  network_security_group_id = azurerm_network_security_group.www_v1_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_vmss" {
  subnet_id                 = var.vmss_subnet_id
  network_security_group_id = azurerm_network_security_group.www_v1_nsg_http.id
}
