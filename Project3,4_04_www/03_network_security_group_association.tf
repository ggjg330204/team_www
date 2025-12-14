resource "azurerm_subnet_network_security_group_association" "vmss_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-web"]
  network_security_group_id = module.security.nsg_http_id
}
resource "azurerm_subnet_network_security_group_association" "acr_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-acr"]
  network_security_group_id = module.security.nsg_http_id
}
resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-db"]
  network_security_group_id = module.security.nsg_db_id
}
resource "azurerm_subnet_network_security_group_association" "storage_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-stor"]
  network_security_group_id = module.security.nsg_db_id
}
resource "azurerm_subnet_network_security_group_association" "hub_bastion_nsg_assoc" {
  subnet_id                 = module.hub.bastion_subnet_id
  network_security_group_id = module.security.nsg_hub_bastion_id
}
resource "azurerm_subnet_network_security_group_association" "was_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-was"]
  network_security_group_id = module.security.nsg_http_id
}

resource "azurerm_subnet_network_security_group_association" "appgw_nsg_assoc" {
  subnet_id                 = module.network_central.subnet_ids["www-appgw"]
  network_security_group_id = module.security.nsg_appgw_id
}
