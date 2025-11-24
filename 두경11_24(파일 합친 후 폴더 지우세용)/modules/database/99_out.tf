output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.www_mysql.fqdn
}

output "mysql_server_id" {
  description = "The ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.www_mysql.id
}


output "redis_hostname" {
  description = "The Hostname of the Redis Instance"
  value       = azurerm_redis_cache.www_redis.hostname
}

output "redis_ssl_port" {
  description = "The SSL Port of the Redis Instance"
  value       = azurerm_redis_cache.www_redis.ssl_port
}

output "redis_primary_key" {
  description = "The Primary Access Key for the Redis Instance"
  value       = azurerm_redis_cache.www_redis.primary_access_key
  sensitive   = true
}

output "adf_name" {
  description = "The name of the Data Factory"
  value       = azurerm_data_factory.www_adf.name
}

output "adf_id" {
  description = "The ID of the Data Factory"
  value       = azurerm_data_factory.www_adf.id
}

output "replica_2_fqdn" {
  value = azurerm_mysql_flexible_server.www_replica_2.fqdn
}
