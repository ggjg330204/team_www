# vnet0 공인 IP (Korea Central)
resource "azurerm_public_ip" "www_basip" {
  name                = "${var.teamuser}-pubip"
  location            = "KoreaCentral"
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_natip" {
  name                = "${var.teamuser}-natip"
  location            = "KoreaCentral"
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}


# vnet1 공인 IP (Korea South)

resource "azurerm_public_ip" "www_loadip" {
  name                = "${var.teamuser}-loadip"
  location            = "KoreaSouth"
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_appip" {
  name                = "${var.teamuser}-appip"
  location            = "KoreaSouth"
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "www_natip_v1" {
  name                = "${var.teamuser}-natip-v1"
  location            = "KoreaSouth"
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}
