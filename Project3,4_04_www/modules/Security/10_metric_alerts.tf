resource "azurerm_monitor_action_group" "main" {
  name                = "www-alerts"
  resource_group_name = var.rgname
  short_name          = "p0-alerts"
  dynamic "email_receiver" {
    for_each = var.admin_emails
    content {
      name          = "admin-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }
  sms_receiver {
    name         = "oncall"
    country_code = "82"
    phone_number = "01012345678"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Alerting"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_monitor_metric_alert" "vmss_cpu" {
  name                = "vmss-cpu-alert"
  resource_group_name = var.rgname
  scopes              = [var.vmss_id]
  description         = "Alert when VMSS CPU exceeds 80%"
  severity            = 2
  enabled             = true
  frequency           = "PT5M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
resource "azurerm_monitor_metric_alert" "mysql_connections" {
  name                = "mysql-connections-alert"
  resource_group_name = var.rgname
  scopes              = [var.mysql_server_id]
  description         = "Alert when MySQL active connections exceed 80%"
  severity            = 2
  enabled             = true
  criteria {
    metric_namespace = "Microsoft.DBforMySQL/flexibleServers"
    metric_name      = "active_connections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 130
  }
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
resource "azurerm_monitor_metric_alert" "redis_memory" {
  name                = "redis-memory-alert"
  resource_group_name = var.rgname
  scopes              = [var.redis_id]
  description         = "Alert when Redis memory usage exceeds 85%"
  severity            = 2
  enabled             = true
  frequency           = "PT5M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
