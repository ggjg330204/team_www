resource "azurerm_private_endpoint" "storage_pe" {
  name                          = "www-storage-endpoint"
  location                      = var.loca
  resource_group_name           = var.rgname
  subnet_id                     = var.storage_subnet_id
  custom_network_interface_name = "www-storage-pe-nic"
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
  resource_group_name = var.rgname
}
resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_link" {
  name                  = "www-storage-dns-link"
  resource_group_name   = var.rgname
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}
