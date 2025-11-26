#project\modules\Security\04_pub.tf
resource "azurerm_public_ip" "www_pip_bas" {
  name                = "www_pip_bas"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_pip_nat" {
  name                = "www_pip_nat"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_pip_app" {
  name                = "www_pip_app"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}