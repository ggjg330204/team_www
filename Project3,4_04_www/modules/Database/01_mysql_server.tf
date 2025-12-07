resource "random_string" "mysql_suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                         = "www-mysql-server-${random_string.mysql_suffix.result}"
  resource_group_name          = var.rgname
  location                     = var.db_location
  administrator_login          = "www"
  administrator_password       = var.db_password
  sku_name                     = "GP_Standard_D4ds_v4"
  version                      = "8.0.21"
  backup_retention_days        = 35
  geo_redundant_backup_enabled = false
  zone                         = "1"
  storage {
    auto_grow_enabled = true
    iops              = 600
    size_gb           = 64
  }
  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  maintenance_window {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 0
  }
  tags = {
    Environment = "Production"
    Purpose     = "Database-Server"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_mysql_flexible_database" "www_db" {
  name                = var.db_name
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
