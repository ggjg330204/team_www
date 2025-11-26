resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_bas" {
  subnet_id                 = var.azurerm_subnet_www_bas
  network_security_group_id = azurerm_network_security_group.www_nsg_ssh.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web1" {
  subnet_id                 = var.azurerm_subnet_www_web1
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web2" {
  subnet_id                 = var.azurerm_subnet_www_web2
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_db" {
  subnet_id                 = var.azurerm_subnet_www_db
  network_security_group_id = azurerm_network_security_group.www_nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_web1" {
  subnet_id                 = var.azurerm_subnet_www_web1_v1
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_v1_asso_subnsg_vmss" {
  subnet_id                 = var.azurerm_subnet_www_web2_v1
  network_security_group_id = azurerm_network_security_group.www_nsg_http.id
}