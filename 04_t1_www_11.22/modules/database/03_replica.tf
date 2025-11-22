# 3. MySQL Replica Server
resource "azurerm_mysql_flexible_server" "www_replica" {
  name                = "www-mysql-replica"
  resource_group_name = var.rgname
  location            = var.loca # Same Region Replica (Cross-Region not supported in this SKU)
  sku_name            = "GP_Standard_D2ds_v4"
  version             = "8.0.21"
  create_mode         = "Replica"
  source_server_id    = azurerm_mysql_flexible_server.www_mysql.id
  
  depends_on = [azurerm_mysql_flexible_server.www_mysql]
}
