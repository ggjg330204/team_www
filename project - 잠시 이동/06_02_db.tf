resource "azurerm_mysql_flexible_database" "www_db" {
  name                = "${var.teamuser}-db"
  resource_group_name = var.rg_name
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}
