# 3. MySQL Replica Server
resource "azurerm_mysql_flexible_server" "www_replica" {
  name                = "www-mysql-replica"
  resource_group_name = var.rgname
  location            = var.replica_loca
  sku_name            = "B_Standard_B2s"
  version             = "8.0.21"
  create_mode         = "Replica"
  source_server_id    = azurerm_mysql_flexible_server.www_mysql.id
}
