resource "azurerm_subnet_nat_gateway_association" "hj_asso_natsub_web" {
  subnet_id      = azurerm_subnet.hj_sub_web.id
  nat_gateway_id = azurerm_nat_gateway.hj_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "hj_asso_natsub_db" {
  subnet_id      = azurerm_subnet.hj_sub_db.id
  nat_gateway_id = azurerm_nat_gateway.hj_nat.id
}
