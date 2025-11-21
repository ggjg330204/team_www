# 1. MySQL Primary Server
resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                   = "www-mysql-server"
  resource_group_name    = var.rgname
  location               = var.loca
  administrator_login    = "adminuser"
  administrator_password = var.db_password
  sku_name               = "B_Standard_B2s"
  version                = "8.0.21"
  backup_retention_days  = 35
}
