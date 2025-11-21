#source\04_pub.tf
resource "azurerm_public_ip" "www_basip" {
  name                = "${var.teamuser}-pubip"
  location            = azurerm_resource_group.www_rg.location
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}
