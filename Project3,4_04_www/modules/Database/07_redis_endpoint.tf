resource "azurerm_private_endpoint" "redis_pe" {
  name                          = "www-redis-endpoint"
  location                      = var.loca
  resource_group_name           = var.rgname
  subnet_id                     = var.db_subnet_id
  custom_network_interface_name = "www-redis-pe-nic"
  private_service_connection {
    name                           = "www-redis-privatelink"
    private_connection_resource_id = azurerm_redis_cache.www_redis.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_dns_zone.id]
  }
}
resource "azurerm_private_dns_zone" "redis_dns_zone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.rgname
}
resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_link" {
  name                  = "www-redis-dns-link"
  resource_group_name   = var.rgname
  private_dns_zone_name = azurerm_private_dns_zone.redis_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}
