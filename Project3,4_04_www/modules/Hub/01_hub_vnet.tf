resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet"
  location            = var.loca
  resource_group_name = var.rgname
  address_space       = [var.hub_address_space]
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != "" ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
  tags = {
    Environment = "Production"
    Purpose     = "Hub-Network"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}
