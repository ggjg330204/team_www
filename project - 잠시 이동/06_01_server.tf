resource "random_string" "mysql_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                   = "www-mysql-server-${random_string.mysql_suffix.result}"
  resource_group_name    = var.rg_name
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D4ds_v4"
  version                = "8.0.21"
  backup_retention_days  = 35
}
