resource "azurerm_private_endpoint" "www_pe" {
  name                = "www-mysql-endpoint"
  location            = var.loca
  resource_group_name = var.rgname
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "www-mysql-privatelink"
    private_connection_resource_id = azurerm_mysql_flexible_server.www_mysql.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.www_dns_zone.id]
  }
}

resource "azurerm_private_dns_zone" "www_dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.rgname
}

resource "azurerm_private_dns_zone_virtual_network_link" "www_dns_link" {
  name                  = "www-dns-link"
  resource_group_name   = var.rgname
  private_dns_zone_name = azurerm_private_dns_zone.www_dns_zone.name
  virtual_network_id    = var.vnet_id
}