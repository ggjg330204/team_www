resource "azurerm_public_ip" "nat_pip" {
  count               = var.enable_nat ? 1 : 0
  name                = "www-nat-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1"]
  tags = {
    Environment = "Production"
    Purpose     = "NAT-Gateway"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes = [zones, tags]
  }
}
resource "azurerm_nat_gateway" "nat_gw" {
  count                   = var.enable_nat ? 1 : 0
  name                    = "www-nat"
  location                = var.loca
  resource_group_name     = var.rgname
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones = ["1"]
  tags = {
    Environment = "Production"
    Purpose     = "NAT-Gateway"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  count                = var.enable_nat ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_gw[0].id
  public_ip_address_id = azurerm_public_ip.nat_pip[0].id
}
resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assoc" {
  count          = var.enable_nat && lookup(azurerm_subnet.subnets, "www-nat", null) != null ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["www-nat"].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw[0].id
}
resource "azurerm_subnet_nat_gateway_association" "nat_vmss_assoc" {
  count          = var.enable_nat && lookup(azurerm_subnet.subnets, "www-vmss", null) != null ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["www-vmss"].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw[0].id
}
resource "azurerm_subnet_nat_gateway_association" "nat_web_assoc" {
  count          = var.enable_nat && lookup(azurerm_subnet.subnets, "www-web", null) != null ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["www-web"].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw[0].id
}
resource "azurerm_subnet_nat_gateway_association" "nat_was_assoc" {
  count          = var.enable_nat && contains(keys(var.subnets), "www-was") ? 1 : 0
  subnet_id      = azurerm_subnet.subnets["www-was"].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw[0].id
}
