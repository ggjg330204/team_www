resource "azurerm_sentinel_alert_rule_scheduled" "ssh_brute_force" {
  name                       = "SSH Brute Force Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "SSH Brute Force Attack"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where Facility == "auth" or Facility == "authpriv"
| where SyslogMessage contains "Failed password"
| extend AttackerIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
| extend TargetUser = extract(@"for\s+(invalid\s+user\s+)?(\w+)", 2, SyslogMessage)
| summarize FailedAttempts = count(), TargetUsers = make_set(TargetUser) by Computer, AttackerIP, Bin = bin(TimeGenerated, 5m)
| where FailedAttempts > 3
| project TimeGenerated = Bin, Computer, AttackerIP, FailedAttempts, TargetUsers
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects 3+ failed SSH login attempts within 5 minutes. Extracts attacker IP and target usernames."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

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
| where SyslogMessage contains "/etc/passwd" 
    or SyslogMessage contains "/etc/shadow"
    or SyslogMessage contains "/etc/sudoers"
    or SyslogMessage contains ".ssh/authorized_keys"
    or SyslogMessage contains ".bash_history"
| extend AccessedFile = extract(@"(/etc/\w+|\.ssh/\w+|\.bash_history)", 1, SyslogMessage)
| project TimeGenerated, Computer, AccessedFile, SyslogMessage
QUERY
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects access to sensitive files: /etc/passwd, shadow, sudoers, SSH keys, bash history."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

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

resource "azurerm_sentinel_alert_rule_scheduled" "waf_attack" {
  name                       = "WAF Attack Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Web Attack Blocked by WAF"
  severity                   = "Medium"
  query                      = <<QUERY
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayFirewallLog"
| extend AttackType = case(
    Message contains "SQL", "SQL Injection",
    Message contains "XSS", "XSS Attack",
    Message contains "command", "Command Injection",
    Message contains "path traversal", "Path Traversal",
    "Other Attack"
)
| project TimeGenerated, Resource, AttackType, Message
QUERY
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects and classifies web attacks blocked by WAF (SQLi, XSS, etc)."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

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
| extend LoginUser = extract(@"for\s+(\w+)\s+from", 1, SyslogMessage)
| extend SourceIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
| project TimeGenerated, Computer, LoginUser, SourceIP, SyslogMessage
QUERY
  query_frequency            = "PT30M"
  query_period               = "PT30M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects logins during off-hours (02:00-05:00 KST). Extracts user and source IP."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

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

resource "azurerm_sentinel_alert_rule_scheduled" "smtp_brute_force" {
  name                       = "SMTP Brute Force Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "SMTP Authentication Brute Force Attack"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where Facility == "mail"
| where SyslogMessage contains "authentication failed" or SyslogMessage contains "SASL LOGIN authentication failed"
| summarize FailedAttempts = count() by Computer, Bin = bin(TimeGenerated, 5m)
| where FailedAttempts > 5
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects 5+ failed SMTP authentication attempts in 5 minutes."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "mail_spoofing" {
  name                       = "Mail Spoofing Attempt"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Email Spoofing Attempt Detected"
  severity                   = "Medium"
  query                      = <<QUERY
Syslog
| where Facility == "mail"
| where SyslogMessage contains "SPF" and (SyslogMessage contains "fail" or SyslogMessage contains "softfail")
| project TimeGenerated, Computer, SyslogMessage
QUERY
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects email spoofing via SPF validation failure."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "privilege_escalation" {
  name                       = "Privilege Escalation Attempt"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Sudo/Su Privilege Escalation Failed"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where Facility == "auth" or Facility == "authpriv"
| where SyslogMessage contains "sudo" and (SyslogMessage contains "NOT in sudoers" or SyslogMessage contains "incorrect password")
| extend User = extract(@"user=(\w+)", 1, SyslogMessage)
| extend Command = extract(@"COMMAND=(.+)", 1, SyslogMessage)
| project TimeGenerated, Computer, User, Command, SyslogMessage
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects failed sudo/su privilege escalation attempts."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_process" {
  name                       = "Suspicious Process Execution"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Suspicious Process/Command Detected"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where SyslogMessage contains "wget" and SyslogMessage contains "http"
    or SyslogMessage contains "curl" and SyslogMessage contains "|"
    or SyslogMessage contains "nc -e"
    or SyslogMessage contains "bash -i"
    or SyslogMessage contains "python -c"
    or SyslogMessage contains "base64 -d"
| extend SuspiciousCommand = extract(@"(wget|curl|nc|bash|python|base64).*", 0, SyslogMessage)
| project TimeGenerated, Computer, SuspiciousCommand, SyslogMessage
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects execution of suspicious commands (reverse shells, downloaders)."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "log_tampering" {
  name                       = "Log Tampering Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Log File Deletion or Tampering"
  severity                   = "High"
  query                      = <<QUERY
Syslog
| where SyslogMessage contains "rm " and SyslogMessage contains "/var/log"
    or SyslogMessage contains "truncate" and SyslogMessage contains "log"
    or SyslogMessage contains "> /var/log"
| extend TamperingCommand = extract(@"(rm|truncate|>).*", 0, SyslogMessage)
| project TimeGenerated, Computer, TamperingCommand, SyslogMessage
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects attempts to delete or tamper with log files."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "mass_http_requests" {
  name                       = "Mass HTTP Request Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Suspicious Mass HTTP Requests"
  severity                   = "Medium"
  query                      = <<QUERY
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| summarize RequestCount = count() by clientIP_s, bin(TimeGenerated, 1m)
| where RequestCount > 100
| project TimeGenerated, AttackerIP = clientIP_s, RequestCount
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects more than 100 HTTP requests per minute from single IP (DDoS/Crawler)."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "port_scan" {
  name                       = "Port Scan Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "Port Scanning Activity Detected"
  severity                   = "Medium"
  query                      = <<QUERY
Syslog
| where Facility == "kern"
| where SyslogMessage contains "BLOCKED" or SyslogMessage contains "DPT="
| extend DestPort = extract(@"DPT=(\d+)", 1, SyslogMessage)
| extend SrcIP = extract(@"SRC=(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
| summarize PortsScanned = dcount(DestPort), AttemptCount = count() by SrcIP, bin(TimeGenerated, 5m)
| where PortsScanned > 10
| project TimeGenerated, AttackerIP = SrcIP, PortsScanned, AttemptCount
QUERY
  query_frequency            = "PT10M"
  query_period               = "PT10M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects port scanning from iptables logs (10+ unique ports in 5 min). Requires iptables logging enabled."
  enabled                    = false

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "break_glass_usage" {
  name                       = "Break Glass Account Usage"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "EMERGENCY: Break Glass Account Used"
  severity                   = "High"
  query                      = <<QUERY
SigninLogs
| where UserPrincipalName contains "breakglass" or UserPrincipalName contains "emergency"
| where ResultType == 0
| project TimeGenerated, UserPrincipalName, IPAddress, Location
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects successful login by emergency break-glass accounts."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}

resource "azurerm_sentinel_alert_rule_scheduled" "fw_deny" {
  name                       = "Firewall Blocked Traffic"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  display_name               = "External Communication Blocked by Firewall"
  severity                   = "High"
  query                      = <<QUERY
union AZFWNetworkRule, AZFWApplicationRule
| where Action contains "Deny"
| extend Destination = case(
    Type == "AZFWNetworkRule", DestinationIp,
    Type == "AZFWApplicationRule", Fqdn,
    "Unknown"
  )
| project TimeGenerated, SourceIp, Destination, Action, Protocol, DestinationPort
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  description                = "Detects traffic blocked by Azure Firewall (Data Exfiltration Attempts)."
  enabled                    = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding]
}
