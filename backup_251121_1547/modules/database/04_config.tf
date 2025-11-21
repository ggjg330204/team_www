# 4. Server Configuration - Audit Logs
resource "azurerm_mysql_flexible_server_configuration" "www_audit" {
  name                = "audit_log_enabled"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "www_audit_events" {
  name                = "audit_log_events"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  value               = "CONNECTION,DDL,DML_SELECT"
}
