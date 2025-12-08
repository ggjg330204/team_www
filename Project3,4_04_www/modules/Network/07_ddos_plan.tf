resource "azurerm_network_ddos_protection_plan" "main" {
  count               = var.enable_ddos ? 1 : 0
  name                = "www-ddos-plan"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "DDoS-Protection"
    ManagedBy   = "Terraform"
  }
}
