#source\04_pub.tf
resource "azurerm_public_ip" "www_basip" {
  name                = "${var.teamuser}-pubip"
  location            = azurerm_resource_group.www_rg.location
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  depends_on = [ azurerm_subnet.www_bas ]
}

resource "azurerm_public_ip" "www_natip" {
  name                = "${var.teamuser}-natip"
  location            = azurerm_resource_group.www_rg.location
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  depends_on = [ azurerm_subnet.www_nat ]
}

resource "azurerm_public_ip" "www_loadip" {
  name                = "${var.teamuser}-loadip"
  location            = azurerm_resource_group.www_rg.location
  resource_group_name = azurerm_resource_group.www_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  depends_on = [ azurerm_subnet.www_load ]
}