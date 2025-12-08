resource "azurerm_security_center_subscription_pricing" "vm" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "kv" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "arm" {
  tier          = "Standard"
  resource_type = "Arm"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = "Standard"
  resource_type = "Dns"
}

# Security Center Contact - Azure API 이슈로 인해 비활성화
# Azure Portal에서 수동 설정 필요:
# Security Center -> Environment settings -> Email notifications
# 
# resource "azurerm_security_center_contact" "contact" {
#   name                = "default"
#   email               = join(";", var.admin_emails)
#   phone               = var.admin_phone
#   alert_notifications = true
#   alerts_to_admins    = true
# }
