resource "azurerm_monitor_diagnostic_setting" "storage_account_diag" {
  name                       = "storage-account-diag"
  target_resource_id         = azurerm_storage_account.www_sa.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob_diag" {
  name                       = "blob-diag"
  target_resource_id         = "${azurerm_storage_account.www_sa.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
  enabled_metric {
    category = "Transaction"
  }
}
