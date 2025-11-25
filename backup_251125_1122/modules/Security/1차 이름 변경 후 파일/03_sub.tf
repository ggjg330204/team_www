#project\modules\Security\03_sub.tf
resource "azurerm_subnet" "www_sub_bas" {
  name                            = "www-sub-bas"
  resource_group_name             = var.rgname
  virtual_network_name            = var.loca
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_sub_nat" {
  name                            = "www-sub-nat"
  resource_group_name             = var.rgname
  virtual_network_name            = var.loca
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_sub_app" {
  name                            = "www-sub-app"
  resource_group_name             = var.rgname
  virtual_network_name            = var.loca
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_sub_web" {
  name                            = "www-sub-web"
  resource_group_name             = var.rgname
  virtual_network_name            = var.loca
  address_prefixes                = ["10.0.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_sub_db" {
  name                            = "www-sub-db"
  resource_group_name             = var.rgname
  virtual_network_name            = var.loca
  address_prefixes                = ["10.0.4.0/24"]
  default_outbound_access_enabled = false
}