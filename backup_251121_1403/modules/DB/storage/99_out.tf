output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.www_sa.name
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.www_sa.primary_access_key
  sensitive   = true
}

output "cdn_endpoint_hostname" {
  description = "The Hostname of the CDN Endpoint"
  value       = "https://${azurerm_cdn_endpoint.www_cdnep.fqdn}"
}
