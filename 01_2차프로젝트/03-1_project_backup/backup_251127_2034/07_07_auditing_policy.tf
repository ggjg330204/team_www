resource "azurerm_log_analytics_workspace" "log" {
  name                = "www-log-analytics"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name                       = "mysql-audit-logs"
  target_resource_id         = azurerm_mysql_flexible_server.www_mysql.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category_group = "audit"
  }
}
