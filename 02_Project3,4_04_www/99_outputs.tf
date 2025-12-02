# ============================================
# 1. 🌐 웹 서비스 접속
# ============================================
output "out_01_web_url" {
  description = "🌐 웹 서비스 주소 (Traffic Manager)"
  value       = "http://${azurerm_traffic_manager_profile.main.fqdn}"
}

# ============================================
# 2. 🔑 관리자 접속 (Azure Bastion)
# ============================================
output "out_10_bastion_vmss_command" {
  description = "🔑 VMSS 인스턴스 SSH 접속 (터널링 방식)"
  value       = "1️⃣ az network bastion tunnel --name ${module.hub.bastion_host_name} --resource-group ${azurerm_resource_group.rg.name} --target-resource-id <VMSS_인스턴스_ID> --resource-port 22 --port 50022\n2️⃣ 새 터미널: ssh -p 50022 www@localhost"
}

output "out_11_vmss_list_command" {
  description = "📋 Web VMSS 인스턴스 목록 확인 (ID 복사용)"
  value       = "az vmss list-instances --name web-vmss --resource-group ${azurerm_resource_group.rg.name} --query \"[].id\" --output tsv"
}

output "out_12_was_vmss_list_command" {
  description = "📋 WAS VMSS 인스턴스 목록 확인 (ID 복사용)"
  value       = "az vmss list-instances --name was-vmss --resource-group ${azurerm_resource_group.rg.name} --query \"[].id\" --output tsv"
}

# ============================================
# 3. 🗄️ 데이터베이스 접속 정보
# ============================================
output "out_20_mysql_connection" {
  description = "🗄️ MySQL 접속 정보"
  value = {
    host     = module.database.mysql_server_fqdn
    port     = 3306
    database = "www_sql"
    username = "www"
    note     = "VMSS/WebVM에서만 접속 가능 (Private Endpoint)"
  }
}

output "out_21_redis_connection" {
  description = "⚡ Redis 접속 정보"
  value = {
    hostname = module.database.redis_hostname
    port     = module.database.redis_ssl_port
    note     = "Primary Key는 Azure Portal에서 확인"
  }
  sensitive = false
}

# ============================================
# 4. 📦 스토리지 및 컨테이너
# ============================================
output "out_30_storage_account" {
  description = "📦 Blob Storage 계정 이름"
  value       = module.storage.storage_account_name
}

output "out_31_acr_server" {
  description = "🐳 ACR 로그인 서버"
  value       = module.container_registry.acr_login_server
}

output "out_32_aci_ip" {
  description = "☁️ ACI 컨테이너 Public IP"
  value       = module.compute.aci_ip
}

# ============================================
# 5. 🛠️ 관리 리소스
# ============================================
output "out_40_resource_group" {
  description = "📂 리소스 그룹 이름"
  value       = azurerm_resource_group.rg.name
}

output "out_41_key_vault" {
  description = "� Key Vault 이름"
  value       = module.security.keyvault_name
}

output "out_42_log_analytics" {
  description = "📊 Log Analytics Workspace ID"
  value       = module.security.log_analytics_workspace_id
}

# ============================================
# 6. 📝 주요 안내사항
# ============================================
output "out_99_important_notes" {
  description = "⚠️ 중요 안내사항"
  value = <<-EOT
  
  ✅ 접속 확인 체크리스트:
  
  1. 웹 서비스 동작 확인:
     - Traffic Manager: ${azurerm_traffic_manager_profile.main.fqdn}
     - CDN 캐시 확인: Front Door 엔드포인트 접속
  
  2. VMSS 인스턴스 접속:
     - 인스턴스 목록 확인 후 Bastion 터널링으로 접속
  
  3. 데이터베이스 연결 테스트:
     - MySQL: VMSS에서 mysql -h ${module.database.mysql_server_fqdn} -u www -p
     - Redis: VMSS에서 redis-cli 테스트
  
  4. 스토리지 확인:
     - az storage blob list --account-name ${module.storage.storage_account_name}
  
  5. 컨테이너 레지스트리:
     - az acr login --name ${replace(module.container_registry.acr_login_server, ".azurecr.io", "")}
  
  EOT
}