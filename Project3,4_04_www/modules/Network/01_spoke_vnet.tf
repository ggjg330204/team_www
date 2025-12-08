resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.loca
  resource_group_name = var.rgname
  address_space       = var.address_space
  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != "" ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
  tags = {
    Environment = "Production"
    Purpose     = "Main-VNet"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
  default_outbound_access_enabled = contains([
    "www-vmss",
    "www-web",
    "www-db",
    "www-stor",
    "www-was"
  ], each.key) ? false : true
  service_endpoints = concat(
    each.key == "www-stor" ? ["Microsoft.Storage"] : [],
    contains(["www-web", "www-was"], each.key) ? ["Microsoft.KeyVault"] : []
  )
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = var.rgname
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}
