#vnet0 pip
resource "azurerm_public_ip" "www_basip" {
  name                = "${var.teamuser}-pubip"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_natip" {
  name                = "${var.teamuser}-natip"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}


#vnet1 pip

resource "azurerm_public_ip" "www_appip" {
  name                = "${var.teamuser}-appip"
  location            = var.loca2
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_natip_v1" {
  name                = "${var.teamuser}-natip-v1"
  location            = var.loca2
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}
