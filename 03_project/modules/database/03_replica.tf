# resource "time_sleep" "wait_for_primary" {
#   create_duration = "2m"
#   depends_on      = [azurerm_mysql_flexible_server.www_mysql]
# }

# resource "azurerm_mysql_flexible_server" "www_replica" {
#   name                = "${var.teamuser}--mysql-replica"
#   resource_group_name = var.rgname
#   location            = var.replica_loca
#   sku_name            = "GP_Standard_D4ds_v4"
#   version             = "8.0.21"
#   create_mode         = "Replica"
#   source_server_id    = azurerm_mysql_flexible_server.www_mysql.id

#   depends_on = [time_sleep.wait_for_primary]
# }

# resource "azurerm_mysql_flexible_server" "www_replica_2" {
#   name                = "${var.teamuser}--mysql-replica-2"
#   resource_group_name = var.rgname
#   location            = var.replica_loca
#   sku_name            = "GP_Standard_D4ds_v4"
#   version             = "8.0.21"
#   create_mode         = "Replica"
#   source_server_id    = azurerm_mysql_flexible_server.www_mysql.id

#   depends_on = [azurerm_mysql_flexible_server.www_mysql]
# }
