#vnet0 natsub
resource "azurerm_subnet_nat_gateway_association" "www_natweb1" {
  subnet_id      = azurerm_subnet.www_web1.id
  nat_gateway_id = azurerm_nat_gateway.www_nat.id

}

resource "azurerm_subnet_nat_gateway_association" "www_natweb2" {
  subnet_id      = azurerm_subnet.www_web2.id
  nat_gateway_id = azurerm_nat_gateway.www_nat.id

}

resource "azurerm_subnet_nat_gateway_association" "www_natdb" {
  subnet_id      = azurerm_subnet.www_db.id
  nat_gateway_id = azurerm_nat_gateway.www_nat.id

}


#vnet1 natsub
resource "azurerm_subnet_nat_gateway_association" "www_natweb1_v1" {
  subnet_id      = azurerm_subnet.www_web1_v1.id
  nat_gateway_id = azurerm_nat_gateway.www_nat_v1.id
}

resource "azurerm_subnet_nat_gateway_association" "www_natweb2_v1" {
  subnet_id      = azurerm_subnet.www_web2_v1.id
  nat_gateway_id = azurerm_nat_gateway.www_nat_v1.id
}

resource "azurerm_subnet_nat_gateway_association" "www_natvmss" {
  subnet_id      = azurerm_subnet.www_vmss.id
  nat_gateway_id = azurerm_nat_gateway.www_nat_v1.id
}

