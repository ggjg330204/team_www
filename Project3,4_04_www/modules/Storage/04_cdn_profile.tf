resource "azurerm_cdn_frontdoor_profile" "www_cdn" {
  name                = var.cdn_profile_name
  resource_group_name = var.rgname
  sku_name            = "Premium_AzureFrontDoor"
  response_timeout_seconds = 120
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
