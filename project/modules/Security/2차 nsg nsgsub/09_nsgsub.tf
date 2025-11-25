resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_bas" {
  subnet_id                 = var.subnet_bas.id
  network_security_group_id = var.www_nsg_ssh
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web1" {
  subnet_id                 = var.subnet_web1.id
  network_security_group_id = var.www_nsg_http
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web2" {
  subnet_id                 = var.subnet_web2.id
  network_security_group_id = var.www_nsg_http
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_db" {
  subnet_id                 = var.subnet_db
  network_security_group_id = var.www_nsg_db
}

resource "azurerm_subnet_network_security_group_association" "www_sth_asso_subnsg_web1" {
  subnet_id                 = var.sth_subnet_web1.id
  network_security_group_id = var.www_sth_nsg_http.id
}

resource "azurerm_subnet_network_security_group_association" "www_sth_asso_subnsg_web2" {
  subnet_id                 = var.sth_subnet_web2.id
  network_security_group_id = var.www_sth_nsg_http.id
}