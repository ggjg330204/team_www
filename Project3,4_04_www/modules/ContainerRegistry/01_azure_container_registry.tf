resource "azurerm_container_registry" "main" {
  name                = "wwwcontainerregistry"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Premium"
  admin_enabled       = false
  zone_redundancy_enabled = true
  network_rule_set {
    default_action = "Deny"
    ip_rule = []
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Container-Registry"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_private_endpoint" "acr" {
  name                = "acr-private-endpoint"
  location            = var.loca
  resource_group_name = var.rgname
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}
