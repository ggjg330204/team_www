output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.www_sa.name
}
output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.www_sa.primary_access_key
  sensitive   = true
}
output "storage_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.www_sa.primary_connection_string
  sensitive   = true
}
output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.www_sa.id
}
