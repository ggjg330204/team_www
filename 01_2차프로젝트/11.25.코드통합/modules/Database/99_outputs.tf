output "mysql_server_fqdn" {
  description = "MySQL Flexible Server의 FQDN"
  value       = azurerm_mysql_flexible_server.www_mysql.fqdn
}

output "mysql_server_id" {
  description = "MySQL Flexible Server의 ID"
  value       = azurerm_mysql_flexible_server.www_mysql.id
}


output "redis_hostname" {
  description = "Redis 인스턴스의 호스트명"
  value       = azurerm_redis_cache.www_redis.hostname
}

output "redis_ssl_port" {
  description = "Redis 인스턴스의 SSL 포트"
  value       = azurerm_redis_cache.www_redis.ssl_port
}

output "redis_primary_key" {
  description = "Redis 인스턴스의 기본 액세스 키"
  value       = azurerm_redis_cache.www_redis.primary_access_key
  sensitive   = true
}

output "adf_name" {
  description = "Data Factory 이름"
  value       = azurerm_data_factory.www_adf.name
}

output "adf_id" {
  description = "Data Factory ID"
  value       = azurerm_data_factory.www_adf.id
}

output "replica_2_fqdn" {
  description = "읽기 전용 복제본(Replica)의 FQDN"
  value       = azurerm_mysql_flexible_server.www_replica_2.fqdn
}
