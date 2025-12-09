resource "azurerm_role_assignment" "pm_owner" {
  scope                = var.rgid
  role_definition_name = "Owner"
  principal_id         = data.azuread_user.pm.object_id
}

resource "azurerm_role_assignment" "pm_sentinel" {
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Microsoft Sentinel Contributor"
  principal_id         = data.azuread_user.pm.object_id
}

resource "azurerm_role_assignment" "pm_monitoring" {
  scope                = var.rgid
  role_definition_name = "Monitoring Contributor"
  principal_id         = data.azuread_user.pm.object_id
}

resource "azurerm_role_assignment" "pm_keyvault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_user.pm.object_id
}

resource "azurerm_role_assignment" "arch_reader" {
  scope                = var.rgid
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.arch_reviewer.object_id
}

resource "azurerm_role_assignment" "sec_external_sentinel" {
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Microsoft Sentinel Contributor"
  principal_id         = data.azuread_user.sec_external.object_id
}

resource "azurerm_role_assignment" "sec_internal1_security_admin" {
  scope                = var.rgid
  role_definition_name = "Security Admin"
  principal_id         = data.azuread_user.sec_internal1.object_id
}

resource "azurerm_role_assignment" "sec_internal2_log_analytics" {
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azuread_user.sec_internal2.object_id
}

resource "azurerm_role_assignment" "sec_external2_sentinel" {
  scope                = var.log_analytics_workspace_id
  role_definition_name = "Microsoft Sentinel Contributor"
  principal_id         = data.azuread_user.sec_external2.object_id
}
