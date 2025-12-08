resource "azurerm_monitor_diagnostic_setting" "appgw_diag" {
  count                      = var.enable_appgw ? 1 : 0
  name                       = "appgw-diag"
  target_resource_id         = azurerm_application_gateway.appgw[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "lb_diag" {
  name                       = "lb-diag"
  target_resource_id         = azurerm_lb.vmss_lb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "was_lb_diag" {
  name                       = "was-lb-diag"
  target_resource_id         = azurerm_lb.was_lb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "lb_pip_diag" {
  name                       = "lb-pip-diag"
  target_resource_id         = azurerm_public_ip.lb_pip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "appgw_pip_diag" {
  count                      = var.enable_appgw ? 1 : 0
  name                       = "appgw-pip-diag"
  target_resource_id         = azurerm_public_ip.appgw_pip[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}
