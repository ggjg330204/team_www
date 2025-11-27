resource "random_string" "mysql_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                   = "www-mysql-server-${random_string.mysql_suffix.result}"
  resource_group_name    = azurerm_resource_group.www_rg.name
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D4ds_v4"
  version                = "8.0.21"
  backup_retention_days  = 35
  zone                   = "1"
  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
}

resource "azurerm_mysql_flexible_database" "www_db" {
  name                = "wordpress"
  resource_group_name = azurerm_resource_group.www_rg.name
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}
