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

resource "random_uuid" "automation_rule_id" {}

resource "azurerm_sentinel_automation_rule" "email_on_incident" {
  name                       = random_uuid.automation_rule_id.result
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Auto-Active Incident"
  order                      = 1
  enabled                    = true

  triggers_on   = "Incidents"
  triggers_when = "Created"

  action_incident {
    order  = 1
    status = "Active"
  }
}

output "action_group_id" {
  value = azurerm_monitor_action_group.sentinel_email.id
}
