#modules\vm.tf\08_natsub.tf
resource "azurerm_subnet_nat_gateway_association" "www_natweb1" {
    subnet_id = azurerm_subnet.www_web1.id
    nat_gateway_id = azurerm_nat_gateway.www_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "www_natdb" {
    subnet_id = azurerm_subnet.www_db.id
    nat_gateway_id = azurerm_nat_gateway.www_nat.id
}