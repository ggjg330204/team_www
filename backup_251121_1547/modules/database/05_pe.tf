# 5. Private Endpoint
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
}
