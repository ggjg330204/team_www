resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name                       = "mysql-audit-logs"
  target_resource_id         = azurerm_mysql_flexible_server.www_mysql.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category = "MySqlAuditLogs"
  }
  enabled_log {
    category = "MySqlSlowLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_monitor_diagnostic_setting" "redis_diag" {
  name                       = "redis-diag"
  target_resource_id         = azurerm_redis_cache.www_redis.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}