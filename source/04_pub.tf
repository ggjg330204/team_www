#source\04_pub.tf
resource "azurerm_public_ip" "www_basip" {
  name                = "www-basip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}