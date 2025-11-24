#project\modules\Security\03_sub.tf
resource "azurerm_subnet" "hj_sub_bas" {
  name                            = "hj-sub-bas"
  resource_group_name             = azurerm_resource_group.hj_rg.name
  virtual_network_name            = azurerm_virtual_network.hj_vnet.name
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "hj_sub_nat" {
  name                            = "hj-sub-nat"
  resource_group_name             = azurerm_resource_group.hj_rg.name
  virtual_network_name            = azurerm_virtual_network.hj_vnet.name
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "hj_sub_app" {
  name                            = "hj-sub-app"
  resource_group_name             = azurerm_resource_group.hj_rg.name
  virtual_network_name            = azurerm_virtual_network.hj_vnet.name
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "hj_sub_web" {
  name                            = "hj-sub-web"
  resource_group_name             = azurerm_resource_group.hj_rg.name
  virtual_network_name            = azurerm_virtual_network.hj_vnet.name
  address_prefixes                = ["10.0.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "hj_sub_db" {
  name                            = "hj-sub-db"
  resource_group_name             = azurerm_resource_group.hj_rg.name
  virtual_network_name            = azurerm_virtual_network.hj_vnet.name
  address_prefixes                = ["10.0.4.0/24"]
  default_outbound_access_enabled = false
}