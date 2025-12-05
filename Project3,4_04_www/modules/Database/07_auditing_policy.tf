resource "azurerm_log_analytics_workspace" "log" {
  name                = "www-log-analytics"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "PerGB2018"
  retention_in_days   = 90
  daily_quota_gb      = 10
}
resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name                       = "mysql-audit-logs"
  target_resource_id         = azurerm_mysql_flexible_server.www_mysql.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
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
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_metric {
    category = "AllMetrics"
  }
}