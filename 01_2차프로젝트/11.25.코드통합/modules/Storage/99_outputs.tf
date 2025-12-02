output "storage_account_name" {
  description = "스토리지 계정 이름"
  value       = azurerm_storage_account.www_sa.name
}

output "primary_access_key" {
  description = "스토리지 계정의 기본 액세스 키"
  value       = azurerm_storage_account.www_sa.primary_access_key
  sensitive   = true
}

output "storage_connection_string" {
  description = "스토리지 계정의 기본 연결 문자열"
  value       = azurerm_storage_account.www_sa.primary_connection_string
  sensitive   = true
}

output "cdn_endpoint_hostname" {
  description = "CDN 엔드포인트 호스트명"
  value       = "https://${azurerm_cdn_frontdoor_endpoint.www_fd_endpoint.host_name}"
}
