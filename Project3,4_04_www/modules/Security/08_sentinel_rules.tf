resource "azurerm_sentinel_alert_rule_scheduled" "ssh_brute_force" {
  name                       = "ssh-brute-force-detection"
  display_name               = "SSH Brute Force Attack"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["CredentialAccess", "InitialAccess"]
  techniques                 = ["T1110"]

  query = <<-QUERY
    Syslog
    | where Facility == "auth" or Facility == "authpriv"
    | where SyslogMessage contains "Failed password"
    | extend AttackerIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | extend TargetUser = extract(@"for\s+(invalid\s+user\s+)?(\w+)", 2, SyslogMessage)
    | summarize FailedAttempts = count(), TargetUsers = make_set(TargetUser) 
        by Computer, AttackerIP, Bin = bin(TimeGenerated, 5m)
    | where FailedAttempts > 3
    | project TimeGenerated = Bin, Computer, AttackerIP, FailedAttempts, TargetUsers
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "smtp_brute_force" {
  name                       = "smtp-brute-force-detection"
  display_name               = "SMTP Brute Force Attack"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["CredentialAccess"]
  techniques                 = ["T1110"]

  query = <<-QUERY
    Syslog
    | where ProcessName == "postfix/smtpd" or ProcessName == "dovecot"
    | where SyslogMessage has_any ("authentication failed", "auth failed", "login failed")
    | extend AttackerIP = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | extend TargetUser = extract(@"user=<([^>]+)>", 1, SyslogMessage)
    | summarize FailedAttempts = count(), TargetUsers = make_set(TargetUser) 
        by Computer, AttackerIP, Bin = bin(TimeGenerated, 5m)
    | where FailedAttempts > 5
    | project TimeGenerated = Bin, Computer, AttackerIP, FailedAttempts, TargetUsers
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "malicious_ip_communication" {
  name                       = "malicious-ip-communication"
  display_name               = "Malicious IP Communication Detected"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["CommandAndControl"]
  techniques                 = ["T1071"]

  query = <<-QUERY
    SecurityAlert
    | where ProviderName == "Azure Security Center"
    | where AlertType has_any ("Network", "Communication", "C2", "Malicious")
    | extend DestIP = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, ExtendedProperties)
    | project TimeGenerated, AlertName, AlertSeverity, Description, DestIP, ResourceId
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "DestIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "privilege_escalation" {
  name                       = "privilege-escalation-attempt"
  display_name               = "Privilege Escalation Attempt"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["PrivilegeEscalation"]
  techniques                 = ["T1548"]

  query = <<-QUERY
    Syslog
    | where Facility == "auth"
    | where SyslogMessage has_any ("sudo", "su")
    | where SyslogMessage has_any ("NOT in sudoers", "authentication failure", "FAILED")
    | extend User = extract(@"user=(\w+)", 1, SyslogMessage)
    | extend Command = extract(@"COMMAND=(.+)$", 1, SyslogMessage)
    | summarize FailedAttempts = count(), Commands = make_set(Command)
        by Computer, User, Bin = bin(TimeGenerated, 5m)
    | where FailedAttempts > 3
    | project TimeGenerated = Bin, Computer, User, FailedAttempts, Commands
  QUERY

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "User"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_process" {
  name                       = "suspicious-process-execution"
  display_name               = "Suspicious Process Execution"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["Execution", "DefenseEvasion"]
  techniques                 = ["T1059"]

  query = <<-QUERY
    Syslog
    | where SyslogMessage has_any ("exec", "EXECVE", "SYSCALL")
    | where SyslogMessage has_any ("nc -e", "bash -i", "wget", "curl", "python -c", "/bin/sh", "ncat", "netcat")
    | where not(ProcessName in ("deploy.sh", "healthcheck.sh", "backup.sh", "was_init.sh"))
    | where not(Computer in ("bastion-vm"))
    | extend Command = extract(@"comm=([^\s]+)", 1, SyslogMessage)
    | extend User = extract(@"uid=(\d+)", 1, SyslogMessage)
    | summarize ExecutionCount = count(), Commands = make_set(Command)
        by Computer, User, bin(TimeGenerated, 5m)
    | where ExecutionCount > 2
  QUERY

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "log_tampering" {
  name                       = "log-tampering-detection"
  display_name               = "Log Tampering Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["DefenseEvasion"]
  techniques                 = ["T1070"]

  query = <<-QUERY
    Syslog
    | where SyslogMessage has_any ("audit", "SYSCALL", "execve")
    | where SyslogMessage has_any ("/var/log", ".log", "history", "wtmp", "lastlog", "messages", "syslog")
    | where SyslogMessage has_any ("unlink", "rm", "truncate", "shred", "history -c")
    | extend User = extract(@"uid=(\d+)", 1, SyslogMessage)
    | extend TargetFile = extract(@"name=([^\s]+)", 1, SyslogMessage)
    | project TimeGenerated, Computer, User, TargetFile, SyslogMessage
  QUERY

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "break_glass_account" {
  name                       = "break-glass-account-usage"
  display_name               = "Break Glass Account Usage"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["InitialAccess", "Persistence"]
  techniques                 = ["T1078"]

  query = <<-QUERY
    Syslog
    | where SyslogMessage has_any ("Accepted password", "session opened", "Accepted publickey")
    | where SyslogMessage has_any ("breakglass", "emergency", "admin-emergency", "root")
    | extend User = extract(@"for\s+(\w+)", 1, SyslogMessage)
    | extend SourceIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | project TimeGenerated, Computer, User, SourceIP, SyslogMessage
  QUERY

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "User"
    }
  }

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SourceIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "firewall_blocked" {
  name                       = "firewall-blocked-traffic"
  display_name               = "Firewall Blocked Traffic"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "High"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  enabled                    = true
  tactics                    = ["CommandAndControl", "Exfiltration"]
  techniques                 = ["T1071"]

  query = <<-QUERY
    union AZFWNetworkRule, AZFWApplicationRule
    | where Action == "Deny"
    | extend SourceIP = SourceIp
    | extend DestIP = coalesce(DestinationIp, Fqdn)
    | extend DestPort = tostring(DestinationPort)
    | where isnotempty(SourceIP)
    | summarize BlockCount = count() by SourceIP, DestIP, DestPort, bin(TimeGenerated, 5m)
    | where BlockCount > 5
    | project TimeGenerated, SourceIP, DestIP, DestPort, BlockCount
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SourceIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "waf_attack" {
  name                       = "waf-attack-detection"
  display_name               = "WAF Attack Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["InitialAccess"]
  techniques                 = ["T1190"]

  query = <<-QUERY
    AzureDiagnostics
    | where ResourceType == "APPLICATIONGATEWAYS"
    | where OperationName == "ApplicationGatewayFirewall"
    | where action_s == "Blocked"
    | extend AttackType = case(
        ruleId_s startswith "942", "SQL Injection",
        ruleId_s startswith "941", "XSS",
        ruleId_s startswith "930", "LFI/RFI",
        ruleId_s startswith "932", "RCE",
        "Other"
    )
    | summarize AttackCount = count() by AttackType, clientIp_s, bin(TimeGenerated, 15m)
    | where AttackCount > 3
    | project TimeGenerated, AttackerIP = clientIp_s, AttackType, AttackCount
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "sensitive_file_access" {
  name                       = "sensitive-file-access"
  display_name               = "Sensitive File Access"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["Collection", "CredentialAccess"]
  techniques                 = ["T1005"]

  query = <<-QUERY
    Syslog
    | where SyslogMessage has_any ("audit", "SYSCALL")
    | where SyslogMessage has_any ("/etc/passwd", "/etc/shadow", "/etc/sudoers", ".ssh", "id_rsa", "authorized_keys")
    | where SyslogMessage has_any ("open", "read", "cat", "less", "more", "vim", "nano")
    | extend User = extract(@"uid=(\d+)", 1, SyslogMessage)
    | extend TargetFile = extract(@"name=([^\s]+)", 1, SyslogMessage)
    | where User != "0"
    | project TimeGenerated, Computer, User, TargetFile, SyslogMessage
  QUERY

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "rbac_change" {
  name                       = "rbac-role-assignment-change"
  display_name               = "RBAC Role Assignment Change"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["Persistence", "PrivilegeEscalation"]
  techniques                 = ["T1098"]

  query = <<-QUERY
    AzureActivity
    | where OperationNameValue has_any ("Microsoft.Authorization/roleAssignments/write", "Microsoft.Authorization/roleAssignments/delete")
    | extend Caller = tostring(parse_json(Claims).["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"])
    | extend RoleDefinitionId = tostring(parse_json(Properties).roleDefinitionId)
    | extend PrincipalId = tostring(parse_json(Properties).principalId)
    | project TimeGenerated, Caller, OperationNameValue, RoleDefinitionId, PrincipalId, ResourceGroup
  QUERY

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "Caller"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "nsg_modification" {
  name                       = "nsg-rule-modification"
  display_name               = "NSG Rule Modification"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["DefenseEvasion", "Persistence"]
  techniques                 = ["T1562"]

  query = <<-QUERY
    AzureActivity
    | where OperationNameValue has_any ("Microsoft.Network/networkSecurityGroups/securityRules/write", "Microsoft.Network/networkSecurityGroups/securityRules/delete")
    | extend Caller = tostring(parse_json(Claims).["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"])
    | extend NSGName = tostring(split(ResourceId, "/")[8])
    | extend RuleName = tostring(split(ResourceId, "/")[10])
    | project TimeGenerated, Caller, OperationNameValue, NSGName, RuleName, ResourceGroup
  QUERY

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "Caller"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "mail_spoofing" {
  name                       = "mail-spoofing-attempt"
  display_name               = "Mail Spoofing Attempt"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT15M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["InitialAccess"]
  techniques                 = ["T1566"]

  query = <<-QUERY
    Syslog
    | where ProcessName has_any ("postfix", "opendkim", "policyd-spf")
    | where SyslogMessage has_any ("SPF fail", "SPF softfail", "DKIM fail", "DMARC fail", "Received-SPF: Fail")
    | extend SenderDomain = extract(@"envelope-from=<[^@]+@([^>]+)>", 1, SyslogMessage)
    | extend SenderIP = extract(@"client=([^[]+)\[(\d+\.\d+\.\d+\.\d+)\]", 2, SyslogMessage)
    | summarize SpoofAttempts = count() by SenderDomain, SenderIP, bin(TimeGenerated, 15m)
    | where SpoofAttempts > 2
    | project TimeGenerated, SenderDomain, SenderIP, SpoofAttempts
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SenderIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "mass_http_requests" {
  name                       = "mass-http-requests"
  display_name               = "Mass HTTP Requests"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Medium"
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["Impact"]
  techniques                 = ["T1498"]

  query = <<-QUERY
    AzureDiagnostics
    | where Category == "ApplicationGatewayAccessLog"
    | summarize RequestCount = count() by clientIP_s, bin(TimeGenerated, 1m)
    | where RequestCount > 100
    | project TimeGenerated, AttackerIP = clientIP_s, RequestCount
  QUERY

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "off_hours_login" {
  name                       = "off-hours-login"
  display_name               = "Off Hours Login"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  severity                   = "Low"
  query_frequency            = "PT30M"
  query_period               = "PT30M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  suppression_enabled        = false
  tactics                    = ["InitialAccess"]
  techniques                 = ["T1078"]

  query = <<-QUERY
    Syslog
    | where SyslogMessage has_any ("Accepted password", "session opened", "Accepted publickey")
    | extend Hour = datetime_part("hour", TimeGenerated)
    | where Hour >= 2 and Hour <= 5
    | extend User = extract(@"for\s+(\w+)", 1, SyslogMessage)
    | extend SourceIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
    | project TimeGenerated, Computer, User, SourceIP, Hour
  QUERY

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "User"
    }
  }

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SourceIP"
    }
  }
}

resource "azurerm_sentinel_automation_rule" "auto_assign_high_severity" {
  name                       = "a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d"
  display_name               = "Auto Assign High Severity Incidents"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  order                      = 1
  enabled                    = true

  condition_json = jsonencode([
    {
      conditionType       = "Property"
      conditionProperties = {
        propertyName   = "IncidentSeverity"
        operator       = "Equals"
        propertyValues = ["High"]
      }
    }
  ])

  action_incident {
    order  = 1
    status = "Active"
    labels = ["auto-response", "high-priority"]
  }
}
