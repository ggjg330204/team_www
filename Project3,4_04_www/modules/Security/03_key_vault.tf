data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "www-kv-${random_id.kv.hex}"
  location                    = var.loca
  resource_group_name         = var.rgname
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  sku_name                    = "premium"
  rbac_authorization_enabled  = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = var.allowed_subnet_ids
    ip_rules = distinct(concat(var.admin_ip_rules, [data.http.my_ip.response_body, "211.227.107.208", "61.108.60.26"]))
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secrets-Management"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
  
  depends_on = [azurerm_role_assignment.kv_admin_sp]
}

resource "random_id" "kv" {
  byte_length = 4
}

resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "kv-diagnostics"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AuditEvent"
  }
  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }
  enabled_metric {
    category = "AllMetrics"
  }
  
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_role_assignment" "kv_admin_sp" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "appgw_kv_role" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.appgw_identity_principal_id
}

resource "azurerm_role_assignment" "vmss_kv_role" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.vmss_identity_principal_id
}