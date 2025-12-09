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

resource "azurerm_logic_app_workflow" "sentinel_playbook" {
  name                = "sentinel-incident-email"
  location            = var.loca
  resource_group_name = var.rgname

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Purpose   = "Sentinel-Alert"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_role_assignment" "sentinel_playbook_contributor" {
  scope                = azurerm_logic_app_workflow.sentinel_playbook.id
  role_definition_name = "Microsoft Sentinel Automation Contributor"
  principal_id         = var.sentinel_service_principal_id
}

resource "azurerm_logic_app_trigger_custom" "sentinel_trigger" {
  name         = "Microsoft_Sentinel_Incident"
  logic_app_id = azurerm_logic_app_workflow.sentinel_playbook.id

  body = <<BODY
{
  "type": "Request",
  "kind": "Http",
  "inputs": {
    "schema": {
      "type": "object",
      "properties": {
        "content": {
          "type": "object"
        }
      }
    }
  }
}
BODY
}

resource "azurerm_role_assignment" "sentinel_responder" {
  scope                = azurerm_log_analytics_workspace.law.id
  role_definition_name = "Microsoft Sentinel Responder"
  principal_id         = azurerm_logic_app_workflow.sentinel_playbook.identity[0].principal_id
}

resource "random_uuid" "automation_rule_id" {}

resource "azurerm_sentinel_automation_rule" "email_on_incident" {
  name                       = random_uuid.automation_rule_id.result
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Send Email on Incident Created"
  order                      = 1
  enabled                    = true

  triggers_on   = "Incidents"
  triggers_when = "Created"

  action_incident {
    order  = 1
    status = "Active"
  }

  action_playbook {
    order        = 2
    logic_app_id = azurerm_logic_app_workflow.sentinel_playbook.id
  }

  depends_on = [
    azurerm_role_assignment.sentinel_playbook_contributor,
    azurerm_role_assignment.sentinel_responder
  ]
}

output "action_group_id" {
  value = azurerm_monitor_action_group.sentinel_email.id
}

output "logic_app_id" {
  value = azurerm_logic_app_workflow.sentinel_playbook.id
}

output "logic_app_name" {
  value = azurerm_logic_app_workflow.sentinel_playbook.name
}
