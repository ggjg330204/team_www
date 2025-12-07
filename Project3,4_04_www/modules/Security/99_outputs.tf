output "nsg_ssh_id" {
  value = azurerm_network_security_group.nsg_ssh.id
}
output "nsg_http_id" {
  value = azurerm_network_security_group.nsg_http.id
}
output "nsg_db_id" {
  value = azurerm_network_security_group.nsg_db.id
}
output "nsg_hub_bastion_id" {
  value = azurerm_network_security_group.nsg_hub_bastion.id
}
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}
output "app_insights_id" {
  value = azurerm_application_insights.app_insights.id
}
output "app_insights_instrumentation_key" {
  value     = azurerm_application_insights.app_insights.instrumentation_key
  sensitive = true
}
output "app_insights_connection_string" {
  value     = azurerm_application_insights.app_insights.connection_string
  sensitive = true
}
output "keyvault_name" {
  value = azurerm_key_vault.kv.name
}
output "keyvault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}
output "nsg_appgw_id" {
  value = azurerm_network_security_group.nsg_appgw.id
}
output "ssl_certificate_secret_id" {
  description = "The secret ID of the SSL certificate in Key Vault"
  value       = azurerm_key_vault_certificate.ssl_cert.secret_id
}

output "data_collection_rule_id" {
  value = azurerm_monitor_data_collection_rule.syslog_dcr.id
}
