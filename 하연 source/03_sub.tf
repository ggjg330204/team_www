#source\03_sub.tf
resource "azurerm_subnet" "www_bas" {
  name                            = "${var.teamuser}-bas"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-bas
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_nat" {
  name                            = "${var.teamuser}-nat"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-nat
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_load" {
  name                            = "${var.teamuser}-load"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-load
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "www_web1" {
  name                            = "${var.teamuser}-web1"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-web1
  address_prefixes                = ["10.0.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "www_db" {
  name                            = "${var.teamuser}-db"
  resource_group_name             = var.rgname
  virtual_network_name            = var.vnet-db
  address_prefixes                = ["10.0.4.0/24"]
  default_outbound_access_enabled = false
}