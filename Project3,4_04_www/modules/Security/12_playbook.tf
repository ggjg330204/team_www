# ============================================
# Sentinel Alert Playbook (Teams 알림)
# ============================================

# Logic App for Teams notification
resource "azurerm_logic_app_workflow" "sentinel_alert_teams" {
  name                = "sentinel-teams-notification"
  location            = var.loca
  resource_group_name = var.rgname

  tags = {
    Purpose   = "Sentinel-SOAR"
    ManagedBy = "Terraform"
  }
}

# NOTE: Logic App의 실제 워크플로우 및 Automation Rule은 Azure Portal에서 설정 권장
# Terraform으로 설정 시 복잡한 JSON 구조 및 권한 문제 발생 가능성 있음.
#
# 수동 설정 가이드:
# 1. Logic App Designer에서 "Sentinel incident" 트리거 및 "Teams post message" 액션 추가
# 2. Sentinel > Automation > Create > Automation rule
# 3. Trigger: When incident is created
# 4. Actions: Run playbook > sentinel-teams-notification
