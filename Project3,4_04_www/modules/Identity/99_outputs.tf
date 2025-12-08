output "vmss_identity_id" {
  value = azurerm_user_assigned_identity.vmss_identity.id
}

output "vmss_identity_principal_id" {
  value = azurerm_user_assigned_identity.vmss_identity.principal_id
}

output "appgw_identity_id" {
  value = azurerm_user_assigned_identity.appgw_identity.id
}

output "appgw_identity_principal_id" {
  value = azurerm_user_assigned_identity.appgw_identity.principal_id
}
