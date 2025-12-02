### vnet
resource "azurerm_virtual_network" "www_vnet_fw" {
  name                = "www-vnet-fw"
  location            = azurerm_resource_group.04-1T-www.location
  resource_group_name = azurerm_resource_group.04-1T-www.name
  address_space       = ["172.17.0.0/16"]
}


### subnet
resource "azurerm_subnet" "www_sub_fw" {
  name                            = "AzureFirewallSubnet"
  resource_group_name             = azurerm_resource_group.04-1T-www.name
  virtual_network_name            = azurerm_virtual_network.www_vnet_fw.name
  address_prefixes                = ["172.17.0.0/26"]
}


### public ip
resource "azurerm_public_ip" "www_pip_fw" {
  name                = "www_pip_fw"
  location            = azurerm_resource_group.04-1T-www.location
  resource_group_name = azurerm_resource_group.04-1T-www.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}


### firewall & firewall ip config
resource "azurerm_firewall" "www_fw" {
  name                = "www-fw"
  location            = azurerm_resource_group.04-1T-www.location
  resource_group_name = azurerm_resource_group.04-1T-www.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "www-ip-fw"
    subnet_id            = azurerm_subnet.www_sub_fw.id
    public_ip_address_id = azurerm_public_ip.www_pip_fw.id
  }
}