resource "azurerm_nat_gateway" "hj_nat" {
  name                    = "hj-nat"
  resource_group_name     = azurerm_resource_group.hj_rg.name
  location                = azurerm_resource_group.hj_rg.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = "4"
}

resource "azurerm_nat_gateway_public_ip_association" "jhj_asso_natpip" {
  nat_gateway_id       = azurerm_nat_gateway.hj_nat.id
  public_ip_address_id = azurerm_public_ip.hj_pip_nat.id
  depends_on = [ azurerm_public_ip.hj_pip_nat ]
}
