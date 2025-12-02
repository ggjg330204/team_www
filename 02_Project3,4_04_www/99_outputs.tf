output "out_01_load_balancer_public_ip" {
  description = "웹서비스 접속 IP (Load Balancer) - 브라우저에 입력하여 접속하세요."
  value       = module.network_central.lb_public_ip
}

output "out_03_traffic_manager_fqdn" {
  description = "글로벌 트래픽매니저 도메인 - 전세계 어디서든 최적의 경로로 접속됩니다."
  value       = "http://${azurerm_traffic_manager_profile.main.fqdn}"
}

output "out_06_aci_ip" {
  description = "ACI (Azure Container Instance) 접속 IP"
  value       = module.compute.aci_ip
}

output "out_10_azure_bastion_connect" {
  description = "[안내] Azure Bastion 접속 방법"
  value       = "Azure Portal > VM 선택 > Connect > Bastion을 통해 안전하게 접속하세요."
}

output "out_12_vmss_instance_list" {
  description = "[명령어] VMSS 인스턴스 목록 및 IP 확인"
  value       = "az vmss nic list --resource-group ${azurerm_resource_group.rg.name} --vmss-name my-vmss --query \"[].ipConfigurations[0].{Instance:id, PrivateIP:privateIpAddress}\" --output table"
}

output "out_13_vmss_ssh_nat_pool" {
  description = "[명령어] VMSS 인스턴스 SSH 접속 (NAT Pool 사용, 포트 50001부터)"
  value       = "ssh -i ./ssh/id_rsa_school -p 50001 www@${module.network_central.lb_public_ip}"
}

output "out_20_resource_group" {
  description = "리소스그룹 이름"
  value       = azurerm_resource_group.rg.name
}

output "out_21_mysql_fqdn" {
  description = "MySQL 데이터베이스 주소 (내부 접속용)"
  value       = module.database.mysql_server_fqdn
}

output "out_22_redis_hostname" {
  description = "Redis 캐시 호스트주소"
  value       = module.database.redis_hostname
}

output "out_23_storage_account" {
  description = "스토리지 계정 이름 (이미지/백업 저장소)"
  value       = module.storage.storage_account_name
}

output "out_24_keyvault_name" {
  description = "Key Vault 이름 (비밀번호/키 암호화)"
  value       = module.security.keyvault_name
}

output "out_25_acr_login_server" {
  description = "컨테이너 레지스트리 주소 (Docker 이미지 저장소)"
  value       = module.container_registry.acr_login_server
}

output "out_30_webvm_private_ip" {
  description = "웹서버 내부 IP"
  value       = module.compute.webvm_private_ip
}

output "out_31_db_private_ip" {
  description = "데이터베이스 내부 IP"
  value       = module.database.mysql_private_endpoint_ip
}

output "out_99_dns_name_servers" {
  description = "도메인 등록 업체에 설정해야 할 네임서버 목록"
  value       = azurerm_dns_zone.public.name_servers
}