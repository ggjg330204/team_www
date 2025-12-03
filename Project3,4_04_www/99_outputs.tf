# ============================================
# 1단계: 인프라 기본 정보
# ============================================

output "resource_group" {
  description = "리소스 그룹 이름"
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "배포 지역"
  value       = azurerm_resource_group.rg.location
}

# ============================================
# 2단계: 웹 서비스 접속
# ============================================

output "web_service_url" {
  description = "웹 서비스 주소 (Traffic Manager)"
  value       = "http://${module.network_central.traffic_manager_fqdn}"
}

# ============================================
# 3단계: VMSS 인스턴스 확인
# ============================================

output "vmss_web_list_command" {
  description = "Web VMSS 인스턴스 목록 조회"
  value       = "az vmss list-instances --name web-vmss --resource-group ${azurerm_resource_group.rg.name} --output table"
}

output "vmss_was_list_command" {
  description = "WAS VMSS 인스턴스 목록 조회"
  value       = "az vmss list-instances --name was-vmss --resource-group ${azurerm_resource_group.rg.name} --output table"
}

# ============================================
# 4단계: VMSS SSH 접속 (Bastion 사용)
# ============================================

output "ssh_connection_guide" {
  description = "VMSS SSH 접속 가이드"
  value       = <<-EOT
  
  [1단계] VMSS 인스턴스 ID 가져오기:
  terraform output vmss_web_list_command
  
  [2단계] Bastion 터널 생성 (PowerShell):
  $vmId = "<인스턴스_ID>"
  az network bastion tunnel --name ${module.hub.bastion_host_name} --resource-group ${azurerm_resource_group.rg.name} --target-resource-id $vmId --resource-port 22 --port 50022
  
  [3단계] 새 터미널에서 SSH 접속:
  ssh -p 50022 www@localhost
  
  EOT
}

# ============================================
# 5단계: 데이터베이스 접속 (VMSS 내부에서만)
# ============================================

output "mysql_host" {
  description = "MySQL 서버 주소"
  value       = module.database.mysql_server_fqdn
}

output "mysql_connection_command" {
  description = "MySQL 접속 명령어 (VMSS 내부에서 실행)"
  value       = "mysql -h ${module.database.mysql_server_fqdn} -u www -p www_sql"
}

output "redis_host" {
  description = "Redis 서버 주소"
  value       = module.database.redis_hostname
}

output "redis_port" {
  description = "Redis SSL 포트"
  value       = module.database.redis_ssl_port
}

output "redis_connection_command" {
  description = "Redis 접속 명령어 (VMSS 내부에서 실행)"
  value       = "redis-cli -h ${module.database.redis_hostname} -p ${module.database.redis_ssl_port} --tls"
}

# ============================================
# 6단계: 스토리지 및 컨테이너
# ============================================

output "storage_account_name" {
  description = "Blob Storage 계정 이름"
  value       = module.storage.storage_account_name
}

output "acr_login_server" {
  description = "ACR 로그인 서버 주소"
  value       = module.container_registry.acr_login_server
}

output "acr_login_command" {
  description = "ACR 로그인 명령어"
  value       = "az acr login --name ${replace(module.container_registry.acr_login_server, ".azurecr.io", "")}"
}

output "aci_public_ip" {
  description = "ACI 컨테이너 Public IP"
  value       = module.compute.aci_ip
}

# ============================================
# 7단계: 보안 및 모니터링
# ============================================

output "key_vault_name" {
  description = "Key Vault 이름"
  value       = module.security.keyvault_name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.security.log_analytics_workspace_id
}

# ============================================
# 전체 가이드 (빠른 참조)
# ============================================

output "quick_start_guide" {
  description = "전체 시작 가이드"
  value       = <<-EOT
  
  ═══════════════════════════════════════════
   Azure 인프라 시작 가이드
  ═══════════════════════════════════════════
  
  ⚠️  처음 시작하시는 분은 아래 문서를 먼저 읽어주세요:
      📄 ./documents/00_Quick_Start_for_Team.md
  
  ───────────────────────────────────────────
  
  [1] 웹 서비스 확인
      🌐 https://www.04www.cloud/
      📊 Traffic Manager: http://${module.network_central.traffic_manager_fqdn}
  
  [2] VMSS 인스턴스 조회
      terraform output vmss_web_list_command
      terraform output vmss_was_list_command
  
  [3] Bastion SSH 접속 (Jumpbox 아님!)
      terraform output ssh_connection_guide
      
      ⭐ Azure Portal 접속 (더 쉬움):
      https://portal.azure.com → VMSS → 인스턴스 → 연결 → Bastion
  
  [4] 데이터베이스 접속 (VMSS 내부에서만 가능)
      terraform output mysql_connection_command
      terraform output redis_connection_command
  
  [5] 컨테이너 레지스트리
      terraform output acr_login_command
  
  ───────────────────────────────────────────
  📚 역할별 상세 가이드:
      - 아키텍처 검증: 00_Quick_Start 섹션 1
      - 데이터 보안: 00_Quick_Start 섹션 2  
      - 앱 보안: 00_Quick_Start 섹션 3
      - 침입 탐지: 00_Quick_Start 섹션 4
  ═══════════════════════════════════════════
  
  EOT
}