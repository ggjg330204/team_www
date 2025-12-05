# resource "azurerm_key_vault_access_policy" "vmss_policy" {
#   key_vault_id = azurerm_key_vault.kv.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = azurerm_user_assigned_identity.vmss_identity.principal_id
# 
#   secret_permissions = [
#     "Get",
#     "List"
#   ]
# }
