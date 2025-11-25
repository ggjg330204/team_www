#modules\vm.tf\07_nat.tf
resource "azurerm_nat_gateway" "www_nat" {
    name = "www-nat"
    resource_group_name = var.rgname
    location = var.loca
    sku_name = "Standard"
    idle_timeout_in_minutes = "4"
}

resource "azurerm_nat_gateway_public_ip_association" "www_nat_pubip" {
  nat_gateway_id = azurerm_nat_gateway.www_nat.id
  public_ip_address_id = azurerm_public_ip.www_natip.id
}