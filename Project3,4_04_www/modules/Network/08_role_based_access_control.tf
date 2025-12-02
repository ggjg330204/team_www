# 1. 리소스 그룹 정보 조회 (Network 모듈의 변수 rgname 사용)
data "azurerm_resource_group" "rg" {
  name = var.rgname
}

# 2. Terraform 실행 클라이언트 정보 (현재 실행 계정 - 멱등성 및 KV 권한용)
data "azurerm_client_config" "current" {}

# 3. 사용자 정보 조회 (제공해주신 정확한 계정 정보 적용)
data "azuread_user" "pm_user" {
  user_principal_name = "student420@mscsschool.onmicrosoft.com"
}
data "azuread_user" "network_admin" {
  user_principal_name = "student424@mscsschool.onmicrosoft.com"
}
data "azuread_user" "compute_admin" {
  user_principal_name = "student411@mscsschool.onmicrosoft.com"
}
data "azuread_user" "db_admin" {
  user_principal_name = "student421@mscsschool.onmicrosoft.com"
}
data "azuread_user" "security_admin" {
  user_principal_name = "student426@mscsschool.onmicrosoft.com"
}

# --- [기존 역할 할당] 리소스 그룹에 대한 사용자 역할 부여 ---

resource "azurerm_role_assignment" "pm_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_user.pm_user.object_id
}
resource "azurerm_role_assignment" "network_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_user.network_admin.object_id
}
resource "azurerm_role_assignment" "compute_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = data.azuread_user.compute_admin.object_id
}
resource "azurerm_role_assignment" "db_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.db_admin.object_id
}
resource "azurerm_role_assignment" "security_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Security Admin"
  principal_id         = data.azuread_user.security_admin.object_id
}

# --- [핵심] 403 Forbidden 오류 해결 및 멱등성 구현 (Key Vault 권한) ---

# A. Terraform 실행자(현재 로그인한 사람)에게 'Key Vault Secrets User' 권한 부여
# -> 이게 있어야 terraform apply 중에 인증서를 읽어올 수 있음
resource "azurerm_role_assignment" "tf_runner_kv_secret_user" {
  # AppGateway와 SSL이 켜져 있고, KeyVault ID가 유효할 때만 생성
  count = var.enable_appgw && var.enable_ssl && var.keyvault_id != "" ? 1 : 0

  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_client_config.current.object_id
}

# B. App Gateway Managed Identity에게 'Key Vault Secrets User' 권한 부여
# -> 이게 있어야 실제 서비스 가동 시 App Gateway가 인증서를 가져감
resource "azurerm_role_assignment" "appgw_identity_kv_user" {
  count = var.enable_appgw && var.enable_ssl && var.keyvault_id != "" ? 1 : 0

  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw_identity[0].principal_id
}