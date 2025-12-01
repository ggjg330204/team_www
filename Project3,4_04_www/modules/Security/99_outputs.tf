output "nsg_ssh_id" {
  value = azurerm_network_security_group.nsg_ssh.id
}
output "nsg_http_id" {
  value = azurerm_network_security_group.nsg_http.id
}
output "nsg_db_id" {
  value = azurerm_network_security_group.nsg_db.id
}
output "nsg_bas_id" {
  value = azurerm_network_security_group.nsg_bas.id
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
