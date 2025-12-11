resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  name                       = "hub-fw-diag"
  target_resource_id         = azurerm_firewall.hub_fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }


}
