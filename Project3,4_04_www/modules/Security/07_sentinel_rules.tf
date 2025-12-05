resource "azurerm_sentinel_alert_rule_scheduled" "ssh_brute_force" {
  name                       = "SSH Brute Force Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "SSH Brute Force Attack"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where Facility == "auth" or Facility == "authpriv"
| where SyslogMessage contains "Failed password"
| summarize count() by Computer, Bin = bin(TimeGenerated, 5m)
| where count_ > 5
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects 5 or more failed SSH login attempts within 5 minutes."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}
# ============================================
# 악성 IP 통신 탐지 (Defender for Cloud 기반)
# ============================================
resource "azurerm_sentinel_alert_rule_scheduled" "malicious_ip" {
  name                       = "Malicious IP Communication"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Communication with Malicious IP (Defender)"
  severity                   = "High"
  query                      = <<QUERY
SecurityAlert
| where TimeGenerated > ago(1h)
| where ProviderName == "Azure Security Center"
| where AlertType contains "Network" or AlertType contains "SSH" or AlertType contains "RDP"
| project TimeGenerated, AlertName, Description, RemediationSteps, ResourceId
QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects network security alerts from Defender for Cloud including suspicious IP communication."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}
resource "azurerm_sentinel_alert_rule_scheduled" "sensitive_file_access" {
  name                       = "Sensitive File Access"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Access to Sensitive Files"
  severity                   = "Medium"
  query                      = <<QUERY
Syslog
| where SyslogMessage contains "/etc/passwd" or SyslogMessage contains "/etc/shadow"
| project TimeGenerated, Computer, SyslogMessage
QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects access attempts to sensitive system files like /etc/passwd."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

# ============================================
# RBAC 권한 변경 탐지 (내부 공격 대응)
# ============================================
resource "azurerm_sentinel_alert_rule_scheduled" "rbac_change" {
  name                       = "RBAC Role Assignment Change"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Azure RBAC Role Assignment Changed"
  severity                   = "Medium"
  query                      = <<QUERY
AzureActivity
| where OperationNameValue contains "MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, CallerIpAddress, OperationNameValue, ResourceGroup
QUERY
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects when Azure RBAC role assignments are created, modified or deleted."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

# ============================================
# 웹 공격 탐지 (AppGW WAF 기반)
# ============================================
resource "azurerm_sentinel_alert_rule_scheduled" "port_scan" {
  name                       = "Port Scan Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Web Attack Detection (WAF)"
  severity                   = "Medium"
  query                      = <<QUERY
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayFirewallLog"
| project TimeGenerated, Resource, Message
QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects web attacks blocked by Application Gateway WAF."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

# ============================================
# 비정상 시간대 로그인 탐지 (내부/외부 공격 대응)
# ============================================
resource "azurerm_sentinel_alert_rule_scheduled" "off_hours_login" {
  name                       = "Off Hours Login"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Login During Off Hours (02:00-05:00)"
  severity                   = "Low"
  query                      = <<QUERY
Syslog
| where Facility == "auth" or Facility == "authpriv"
| where SyslogMessage contains "Accepted"
| extend Hour = datetime_part("hour", TimeGenerated)
| where Hour >= 2 and Hour <= 5
| project TimeGenerated, Computer, SyslogMessage
QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects successful logins during off-business hours (02:00-05:00 KST)."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

# ============================================
# NSG 규칙 변경 탐지 (보안 설정 변조 탐지)
# ============================================
resource "azurerm_sentinel_alert_rule_scheduled" "nsg_rule_change" {
  name                       = "NSG Rule Modification"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Network Security Group Rule Modified"
  severity                   = "Medium"
  query                      = <<QUERY
AzureActivity
| where OperationNameValue contains "MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/SECURITYRULES"
| where ActivityStatusValue == "Success"
| project TimeGenerated, Caller, CallerIpAddress, OperationNameValue, ResourceGroup
QUERY
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects when NSG security rules are created, modified or deleted."
  enabled                    = true
  
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}
