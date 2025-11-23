#project\modules\Security\04_pub.tf
resource "azurerm_public_ip" "hj_pip_bas" {
  name                = "hj_pip_bas"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "hj_pip_nat" {
  name                = "hj_pip_nat"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "hj_pip_app" {
  name                = "hj_pip_app"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}