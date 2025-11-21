# 6. CDN Profile (Azure Front Door Standard)
resource "azurerm_cdn_frontdoor_profile" "www_fd_profile" {
  name                = var.cdn_profile_name
  resource_group_name = var.rgname
  sku_name            = "Standard_AzureFrontDoor"
}
