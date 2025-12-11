resource "azurerm_security_center_subscription_pricing" "vm" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "kv" {
  tier          = "Standard"
  resource_type = "KeyVaults"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "arm" {
  tier          = "Standard"
  resource_type = "Arm"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Standard"
  resource_type = "Containers"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = "Standard"
  resource_type = "Dns"
  lifecycle {
    ignore_changes = all
  }
}