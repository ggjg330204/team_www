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

/*
resource "azurerm_sentinel_data_connector_threat_intelligence_taxii" "taxii" {
  name                       = "threat-intelligence-taxii-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  display_name               = "Standard TAXII Connector"
  api_root_url               = "https://limo.anomali.com/api/v1/taxii2/feeds"
  collection_id              = "107"
  user_name                  = "guest"
  password                   = "guest"
}

resource "azurerm_sentinel_data_connector_microsoft_threat_intelligence" "mstid" {
  name                                         = "microsoft-threat-intelligence-connector"
  log_analytics_workspace_id                   = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  microsoft_emerging_threat_feed_lookback_date = "1970-01-01T00:00:00Z"
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "mcas" {
  name                       = "microsoft-cloud-app-security-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  tenant_id                  = var.tenant_id
}

resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "mdatp" {
  name                       = "microsoft-defender-atp-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  tenant_id                  = var.tenant_id
}

resource "azurerm_sentinel_data_connector_azure_advanced_threat_protection" "aatp" {
  name                       = "azure-advanced-threat-protection-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  tenant_id                  = var.tenant_id
}

resource "azurerm_sentinel_data_connector_office_365" "office_365" {
  name                       = "office-365-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}

resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  name                       = "azure-active-directory-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}
*/


