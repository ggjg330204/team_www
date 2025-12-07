resource "azurerm_recovery_services_vault" "vault" {
  name                = "www-recovery-vault"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  soft_delete_enabled = false
  lifecycle {
    create_before_destroy = false
  }
}
resource "azurerm_backup_policy_vm" "daily" {
  name                = "daily-backup-policy"
  resource_group_name = var.rgname
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone = "Korea Standard Time"
  backup {
    frequency = "Daily"
    time      = "02:00"
  }
  retention_daily {
    count = 35
  }
  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }
  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
  retention_yearly {
    count    = 7
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
  instant_restore_retention_days = 5
  lifecycle {
    create_before_destroy = false
  }
}

