resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_bas" {
  subnet_id                 = var.subnet_bas.id
  network_security_group_id = var.www_nsg_ssh
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_web" {
  subnet_id                 = var.subnet_web.id
  network_security_group_id = var.www_nsg_http
}

resource "azurerm_subnet_network_security_group_association" "www_asso_subnsg_db" {
  subnet_id                 = var.subnet_db
  network_security_group_id = var.www_nsg_db
}

resource "azurerm_subnet_network_security_group_association" "www_sth_asso_subnsg_web" {
  subnet_id                 = var.sth_subnet_web.id
  network_security_group_id = var.www_sth_nsg_http.id
}