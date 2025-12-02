resource "azurerm_role_assignment" "pm_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_user.pm_user.object_id
}
resource "azurerm_role_assignment" "network_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_user.network_admin.object_id
}
resource "azurerm_role_assignment" "compute_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = data.azuread_user.compute_admin.object_id
}
resource "azurerm_role_assignment" "db_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.db_admin.object_id
}
resource "azurerm_role_assignment" "security_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Security Admin"
  principal_id         = data.azuread_user.security_admin.object_id
}
