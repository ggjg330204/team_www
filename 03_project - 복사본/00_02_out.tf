#source\99_out.tf
output "bas_pub_ip" {
  value = azurerm_public_ip.www_basip.ip_address
}
output "nat_pub_ip" {
  value = azurerm_public_ip.www_natip.ip_address
}

output "app_pub_ip" {
  value = azurerm_public_ip.www_appip.ip_address
}
output "nat_v1_pub_ip" {
  value = azurerm_public_ip.www_natip_v1.ip_address
}

# --- Storage Outputs ---
output "storage_account_name" {
  value = azurerm_storage_account.www_sa.name
}

output "storage_primary_connection_string" {
  value     = azurerm_storage_account.www_sa.primary_connection_string
  sensitive = true
}

# --- Database Outputs ---
output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.www_mysql.fqdn
}

output "redis_hostname" {
  value = azurerm_redis_cache.www_redis.hostname
}

output "adf_name" {
  value = azurerm_data_factory.www_adf.name
}
