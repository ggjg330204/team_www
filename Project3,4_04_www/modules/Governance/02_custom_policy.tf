data "azurerm_client_config" "current" {}

resource "random_string" "policy_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_policy_definition" "secure_transfer" {
  name         = "secure-transfer-${random_string.policy_suffix.result}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Secure Transfer Required (${random_string.policy_suffix.result})"
  description  = "Force Secure Transfer Required to be set to true on Storage Accounts."
  metadata     = <<METADATA
    {
      "category": "Storage"
    }
METADATA
  policy_rule  = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
            "notEquals": "true"
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    }
POLICY_RULE

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_group_policy_assignment" "assign_secure_transfer" {
  name                 = "assign-secure-transfer"
  resource_group_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.rgname}"
  policy_definition_id = azurerm_policy_definition.secure_transfer.id
}

resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations-${random_string.policy_suffix.result}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed Locations (${random_string.policy_suffix.result})"
  description  = "This policy enables you to restrict the locations your organization can specify when deploying resources."
  metadata     = <<METADATA
    {
      "category": "General"
    }
METADATA
  policy_rule  = <<POLICY_RULE
    {
      "if": {
        "not": {
          "field": "location",
          "in": ["koreacentral", "global"]
        }
      },
      "then": {
        "effect": "Deny"
      }
    }
POLICY_RULE

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_group_policy_assignment" "assign_allowed_locations" {
  name                 = "assign-allowed-locations"
  resource_group_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.rgname}"
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
}
