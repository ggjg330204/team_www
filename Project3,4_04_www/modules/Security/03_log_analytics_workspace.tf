resource "azurerm_log_analytics_workspace" "law" {
  name                = "www-law"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "PerGB2018"
  retention_in_days = 90
  daily_quota_gb = 10
  tags = {
    Environment = "Production"
    Purpose     = "Monitoring-Logs"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_log_analytics_solution" "sentinel" {
  solution_name         = "SecurityInsights"
  location              = var.loca
  resource_group_name   = var.rgname
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel_onboarding" {
  workspace_id = azurerm_log_analytics_workspace.law.id
  
  depends_on = [azurerm_log_analytics_solution.sentinel]
}
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = var.loca
  resource_group_name   = var.rgname
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}
resource "azurerm_log_analytics_solution" "updates" {
  solution_name         = "Updates"
  location              = var.loca
  resource_group_name   = var.rgname
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}
