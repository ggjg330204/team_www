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

resource "azurerm_mysql_flexible_server_configuration" "no_ssl" {
  name                = "require_secure_transport"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_class_ip" {
  name                = "allow-class-ip"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.www_mysql.name
  start_ip_address    = "61.108.60.26"
  end_ip_address      = "61.108.60.26"
}