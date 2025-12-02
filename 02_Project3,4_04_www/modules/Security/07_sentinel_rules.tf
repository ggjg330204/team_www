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
resource "azurerm_sentinel_alert_rule_scheduled" "malicious_ip" {
  name                       = "Malicious IP Communication"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Communication with Malicious IP"
  severity                   = "High"
  query                      = <<QUERY
AzureDiagnostics
| where TimeGenerated > ago(1h)
| where ResourceType contains "FIREWALL"
| take 1
QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 9999
  description                = "Azure Firewall traffic monitoring (Disabled - requires log data for schema verification)"
  enabled                    = false
  
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
