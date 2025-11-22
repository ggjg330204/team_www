# 2. Database
resource "azurerm_mysql_flexible_database" "www_db" {
  name                = var.db_name
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}
