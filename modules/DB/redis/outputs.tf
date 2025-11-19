output "hostname" {
  description = "The Hostname of the Redis Instance"
  value       = azurerm_redis_cache.main.hostname
}

output "ssl_port" {
  description = "The SSL Port of the Redis Instance"
  value       = azurerm_redis_cache.main.ssl_port
}

output "primary_access_key" {
  description = "The Primary Access Key for the Redis Instance"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

/*
### 학습 포인트 (Redis Outputs)
- 웹 서버(WordPress) 설정 파일(`wp-config.php`)에 이 호스트명과 키를 넣으면 Redis를 사용할 수 있습니다.
*/
