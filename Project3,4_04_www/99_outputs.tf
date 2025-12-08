output "resource_group" {
  description = "리소스 그룹"
  value       = azurerm_resource_group.rg.name
}

output "web_service_url" {
  description = "웹 서비스 (Front Door)"
  value       = "https://www.${var.domain_name}/"
}

output "traffic_manager_url" {
  description = "Traffic Manager (백업)"
  value       = "http://${module.network_central.traffic_manager_fqdn}"
}

output "mysql_host" {
  description = "MySQL 호스트 (VMSS 내부에서만 접속 가능)"
  value       = module.database.mysql_server_fqdn
}

output "frontdoor_validation_tokens" {
  description = "Front Door 도메인 검증 토큰 (DNS 설정 시 필요)"
  value = {
    www_token  = module.edge.www_custom_domain_validation_token
    apex_token = module.edge.apex_custom_domain_validation_token
  }
  sensitive = true
}

output "redis_host" {
  description = "Redis Hostname"
  value       = module.database.redis_hostname
}

output "key_vault_name" {
  description = "The Name of the Key Vault"
  value       = module.security.keyvault_name
}

output "frontdoor_endpoint_hostname" {
  description = "Hostname of the Front Door Endpoint"
  value       = module.edge.frontdoor_endpoint_hostname
}