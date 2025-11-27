resource "random_string" "replica_suffix" {
  length  = 2
  special = false
  upper   = false
  numeric = true
}

resource "time_sleep" "wait_for_primary" {
  create_duration = "2m"
  depends_on      = [azurerm_mysql_flexible_server.www_mysql]
}

resource "azurerm_mysql_flexible_server" "www_replica" {
  name                   = "www-mysql-replica-1-${random_string.replica_suffix.result}"
  resource_group_name    = azurerm_resource_group.www_rg.name
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2ds_v4"
  zone                   = "2"
  create_mode            = "Replica"
  source_server_id       = azurerm_mysql_flexible_server.www_mysql.id
  depends_on             = [time_sleep.wait_for_primary]
}

resource "azurerm_mysql_flexible_server" "www_replica_2" {
  name                   = "www-mysql-replica-2-${random_string.replica_suffix.result}"
  resource_group_name    = azurerm_resource_group.www_rg.name
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2ds_v4"
  zone                   = "1"
  create_mode            = "Replica"
  source_server_id       = azurerm_mysql_flexible_server.www_mysql.id
  depends_on             = [time_sleep.wait_for_primary]
}
