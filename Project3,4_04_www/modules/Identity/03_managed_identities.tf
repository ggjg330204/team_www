resource "azurerm_user_assigned_identity" "vmss_identity" {
  location            = var.loca
  name                = "vmss-managed-identity"
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "VMSS-Identity"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_user_assigned_identity" "appgw_identity" {
  location            = var.loca
  name                = "appgw-managed-identity"
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "Application-Gateway"
    ManagedBy   = "Terraform"
  }
}
