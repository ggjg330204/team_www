resource "azurerm_cdn_frontdoor_profile" "www_fd_profile" {
  name                = "${var.teamuser}-cdn-profile"
  resource_group_name = azurerm_resource_group.www_rg.name
  sku_name            = "Standard_AzureFrontDoor"
}
