resource "azurerm_security_center_subscription_pricing" "vm" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  lifecycle {
    ignore_changes  = all
  }
}
resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
  lifecycle {
    ignore_changes  = all
  }
}
resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan = "DefenderForStorageV2"
  lifecycle {
    ignore_changes  = all
  }
}
resource "azurerm_security_center_subscription_pricing" "keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
  lifecycle {
    ignore_changes  = all
  }
}
resource "azurerm_security_center_contact" "main" {
  name  = "contact1"
  email = "security@example.com"
  phone = "+82-10-1234-5678"
  alert_notifications = true
  alerts_to_admins    = true
  lifecycle {
    ignore_changes  = all
  }
}
