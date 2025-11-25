#vnet0 sub
resource "azurerm_subnet" "www_bas" {
  name                            = "${var.teamuser}-bas"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet0.name
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_nat" {
  name                            = "${var.teamuser}-nat"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet0.name
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_web1" {
  name                            = "${var.teamuser}-web1"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet0.name
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_web2" {
  name                            = "${var.teamuser}-web2"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet0.name
  address_prefixes                = ["10.0.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_db" {
  name                            = "${var.teamuser}-db"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet0.name
  address_prefixes                = ["10.0.4.0/24"]
  default_outbound_access_enabled = false
}

#vnet1 sub
resource "azurerm_subnet" "www_app" {
  name                            = "${var.teamuser}-app"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_nat_v1" {
  name                            = "${var.teamuser}-nat-v1"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.1.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_load" {
  name                            = "${var.teamuser}-load"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.2.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_web1_v1" {
  name                            = "${var.teamuser}-web1-v1"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_web2_v1" {
  name                            = "${var.teamuser}-web2-v1"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.4.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_vmss" {
  name                            = "${var.teamuser}-vmss"
  resource_group_name             = azurerm_resource_group.www_rg.name
  virtual_network_name            = azurerm_virtual_network.www_vnet1.name
  address_prefixes                = ["192.168.5.0/24"]
  default_outbound_access_enabled = false
}
