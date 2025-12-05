resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  name                       = "vmss-diag"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "was_vmss_diag" {
  name                       = "was-vmss-diag"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.was_vmss.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}
