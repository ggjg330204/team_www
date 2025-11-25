#vnet0 nat
resource "azurerm_nat_gateway" "www_nat" {
  name                    = "${var.teamuser}-nat"
  resource_group_name     = azurerm_resource_group.www_rg.name
  location                = "KoreaCentral"
  sku_name                = "Standard"
  idle_timeout_in_minutes = "4"

}

resource "azurerm_nat_gateway_public_ip_association" "www_nat_pubip" {
  nat_gateway_id       = azurerm_nat_gateway.www_nat.id
  public_ip_address_id = azurerm_public_ip.www_natip.id
}


#vnet1 nat
resource "azurerm_nat_gateway" "www_nat_v1" {
  name                    = "${var.teamuser}-nat-v1"
  resource_group_name     = azurerm_resource_group.www_rg.name
  location                = "KoreaSouth"
  sku_name                = "Standard"
  idle_timeout_in_minutes = "4"

}

resource "azurerm_nat_gateway_public_ip_association" "www_nat_v1_pubip" {
  nat_gateway_id       = azurerm_nat_gateway.www_nat_v1.id
  public_ip_address_id = azurerm_public_ip.www_natip_v1.id
}