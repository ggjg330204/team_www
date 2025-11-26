# 7. CDN Endpoint
resource "azurerm_cdn_endpoint" "www_cdnep" {
  name                = "www-cdn-endpoint-${random_string.cdn_suffix.result}"
  profile_name        = azurerm_cdn_profile.www_cdnpro.name
  location            = azurerm_cdn_profile.www_cdnpro.location
  resource_group_name = var.rgname

  origin {
    name      = "storage-origin"
    host_name = "${azurerm_storage_account.www_sa.name}.blob.core.windows.net"
  }
}

resource "random_string" "cdn_suffix" {
  length  = 6
  special = false
  upper   = false
}
