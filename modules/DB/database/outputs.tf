output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_server_id" {
  description = "The ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.id
}

output "replica_server_fqdn" {
  description = "The FQDN of the Replica Server"
  value       = azurerm_mysql_flexible_server.replica.fqdn
}

/*
### 학습 포인트 (Outputs)
1. **output**: 모듈이 작업을 마치고 밖으로 던져주는 결과값입니다. 함수로 치면 `return` 값입니다.
2. **value**: 실제로 내보낼 값입니다. 보통 만들어진 리소스의 ID나 접속 주소(FQDN)를 내보냅니다.
3. **용도**: 여기서 내보낸 값은 루트 모듈(`main.tf`)이나 다른 모듈에서 `module.database.mysql_server_fqdn` 형태로 가져다 쓸 수 있습니다.
*/
