resource "azurerm_private_endpoint" "storage_pe" {
  name                = "www-storage-endpoint"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
  subnet_id           = azurerm_subnet.www_db.id

  private_service_connection {
    name                           = "www-storage-privatelink"
    private_connection_resource_id = azurerm_storage_account.www_sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns_zone.id]
  }
}

resource "azurerm_private_dns_zone" "storage_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.www_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_link" {
  name                  = "www-storage-dns-link"
  resource_group_name   = azurerm_resource_group.www_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.www_vnet0.id
}
