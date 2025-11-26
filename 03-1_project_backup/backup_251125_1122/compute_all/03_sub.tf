#source\03_sub.tf
#count=6
resource "azurerm_subnet" "www_bas" {
  name                            = "${var.teamuser}-bas"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_nat" {
  name                            = "${var.teamuser}-nat"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = true
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_load" {
  name                            = "${var.teamuser}-load"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = true
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_web1" {
  name                            = "${var.teamuser}-web1"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.3.0/24"]
  default_outbound_access_enabled = false
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_web2" {
  name                            = "${var.teamuser}-web2"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.4.0/24"]
  default_outbound_access_enabled = false
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_db" {
  name                            = "${var.teamuser}-db"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.5.0/24"]
  default_outbound_access_enabled = false
  depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_vmss" {
  name                            = "${var.teamuser}-vmss"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet.name
  address_prefixes                = ["10.0.6.0/24"]
  default_outbound_access_enabled = false
  depends_on = [ azurerm_virtual_network.www_vnet ]
}