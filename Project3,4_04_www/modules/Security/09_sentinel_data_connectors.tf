# ============================================
# Sentinel Data Connectors
# ============================================
# NOTE: Data Connector들은 Azure Portal에서 수동으로 활성화해야 합니다.
# Terraform에서는 전역 관리자/Sentinel 기여자 권한이 필요합니다.
#
# 수동 활성화 방법:
# Azure Portal → Microsoft Sentinel → Data connectors
# - Azure Active Directory 커넥터 활성화
# - Azure Security Center (Defender for Cloud) 커넥터 활성화
# - Azure Activity 커넥터 활성화

# resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
#   name                       = "aad-connector"
#   log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
#   depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
# }

# resource "azurerm_sentinel_data_connector_azure_security_center" "asc" {
#   name                       = "asc-connector"
#   log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
#   depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
# }


