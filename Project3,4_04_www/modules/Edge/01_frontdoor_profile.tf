resource "azurerm_cdn_frontdoor_profile" "www_cdn" {
  name                = var.cdn_profile_name
  resource_group_name = var.rgname
  sku_name            = "Premium_AzureFrontDoor"
  response_timeout_seconds = 120
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
  
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "frontdoor_kv_role" {
  count                = var.keyvault_certificate_secret_id != "" ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_cdn_frontdoor_profile.www_cdn.identity[0].principal_id
}
