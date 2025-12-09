resource "azurerm_monitor_action_group" "sentinel_email" {
  name                = "sentinel-alert-email"
  resource_group_name = var.rgname
  short_name          = "SentinelMail"

  dynamic "email_receiver" {
    for_each = var.admin_emails
    content {
      name                    = "sentinel-admin-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = {
    Purpose   = "Sentinel-Alert"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sentinel_high_severity" {
  name                = "sentinel-high-severity-incident"
  resource_group_name = var.rgname
  location            = var.loca
  description         = "High/Critical severity Sentinel incidents detected"
  display_name        = "🚨 Sentinel High/Critical Incident"
  enabled             = true
  severity            = 1

  scopes                = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency  = "PT15M"
  window_duration       = "PT15M"
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]

  criteria {
    query = <<-QUERY
      SecurityIncident
      | where TimeGenerated > ago(15m)
      | where Severity in ("High", "Critical")
      | project TimeGenerated, Title, Severity, Status, IncidentNumber, IncidentUrl
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    dimension {
      name     = "Title"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "Severity"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.sentinel_email.id]
  }

  tags = {
    Purpose   = "Sentinel-Alert"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sentinel_medium_severity" {
  name                = "sentinel-medium-severity-incident"
  resource_group_name = var.rgname
  location            = var.loca
  description         = "Medium severity Sentinel incidents detected"
  display_name        = "⚠️ Sentinel Medium Incident"
  enabled             = false
  severity            = 2

  scopes                = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency  = "PT10M"
  window_duration       = "PT10M"
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]

  criteria {
    query = <<-QUERY
      SecurityIncident
      | where TimeGenerated > ago(10m)
      | where Severity == "Medium"
      | project TimeGenerated, Title, Severity, Status, IncidentNumber
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    dimension {
      name     = "Title"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.sentinel_email.id]
  }

  tags = {
    Purpose   = "Sentinel-Alert"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "security_alert" {
  name                = "sentinel-security-alert"
  resource_group_name = var.rgname
  location            = var.loca
  description         = "Security alerts from Defender for Cloud"
  display_name        = "🛡️ Security Alert Detected"
  enabled             = true
  severity            = 2

  scopes                = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency  = "PT30M"
  window_duration       = "PT30M"
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]

  criteria {
    query = <<-QUERY
      SecurityAlert
      | where TimeGenerated > ago(30m)
      | where AlertSeverity in ("High", "Critical")
      | project TimeGenerated, AlertName, AlertSeverity, Description
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    dimension {
      name     = "AlertName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.sentinel_email.id]
  }

  tags = {
    Purpose   = "Sentinel-Alert"
    ManagedBy = "Terraform"
  }
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.sentinel_email.id
  description = "Action Group ID for Sentinel alerts"
}

output "action_group_name" {
  value       = azurerm_monitor_action_group.sentinel_email.name
  description = "Action Group name"
}
