resource "azurerm_sentinel_data_connector_azure_security_center" "defender_cloud" {
  name                       = "DefenderForCloudConnector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  subscription_id            = var.subscription_id

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

data "azurerm_subscription" "current" {}

resource "azurerm_monitor_diagnostic_setting" "subscription_activity_logs" {
  count                      = var.enable_activity_logs ? 1 : 0
  name                       = "terraform-sentinel-activity-logs"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}

