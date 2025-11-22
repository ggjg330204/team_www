# 1. MySQL Primary Server
resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                   = "www-mysql-server"
  resource_group_name    = var.rgname
  location               = var.loca
  administrator_login    = "adminuser"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2ds_v4"
  version                = "8.0.21"
  backup_retention_days  = 35
}
