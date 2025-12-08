resource "azurerm_application_insights" "app_insights" {
  name                 = "www-app-insights"
  location             = var.loca
  resource_group_name  = var.rgname
  application_type     = "web"
  workspace_id         = azurerm_log_analytics_workspace.law.id
  retention_in_days    = 90
  daily_data_cap_in_gb = 5
  sampling_percentage  = 100
  tags = {
    Environment = "Production"
    Purpose     = "Application-Monitoring"
    ManagedBy   = "Terraform"
  }
}
