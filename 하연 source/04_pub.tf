#source\04_pub.tf
resource "azurerm_public_ip" "www_basip" {
  name                = "${var.teamuser}-pubip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_natip" {
  name                = "${var.teamuser}-natip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_loadip" {
  name                = "${var.teamuser}-loadip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}