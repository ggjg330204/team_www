resource "random_string" "replica_suffix" {
  length  = 2
  special = false
  upper   = false
  numeric = true
}
resource "time_sleep" "wait_for_primary" {
  create_duration = "5m"
  depends_on      = [azurerm_mysql_flexible_server.www_mysql]
}
resource "azurerm_mysql_flexible_server" "www_replica" {
  name                   = "www-mysql-replica-1-${random_string.replica_suffix.result}"
  resource_group_name    = var.rgname
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2ds_v4"
  zone                   = "2"
  create_mode            = "Replica"
  source_server_id       = azurerm_mysql_flexible_server.www_mysql.id
  storage {
    auto_grow_enabled = true
  }
  depends_on = [time_sleep.wait_for_primary]
  tags = {
    Environment = "Production"
    Purpose     = "Database-Replica"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_mysql_flexible_server" "www_replica_2" {
  name                   = "www-mysql-replica-2-${random_string.replica_suffix.result}"
  resource_group_name    = var.rgname
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2ds_v4"
  zone                   = "1"
  create_mode            = "Replica"
  source_server_id       = azurerm_mysql_flexible_server.www_mysql.id
  storage {
    auto_grow_enabled = true
  }
  depends_on = [azurerm_mysql_flexible_server.www_replica]
}
