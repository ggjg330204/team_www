resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = "syslog-dcr"
  resource_group_name = var.rgname
  location            = var.loca

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "law"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law"]
  }

  data_sources {
    syslog {
      facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "kern",
        "syslog",
        "user"
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
      name    = "syslog-datasource"
      streams = ["Microsoft-Syslog"]
    }
  }
}

