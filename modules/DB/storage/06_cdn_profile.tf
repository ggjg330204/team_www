# 6. CDN Profile
resource "azurerm_cdn_profile" "www_cdnpro" {
  name                = var.cdn_profile_name
  location            = "global"
  resource_group_name = var.rgname
  sku                 = "Standard_Microsoft"
}
