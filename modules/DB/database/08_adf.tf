# 8. Data Factory
resource "azurerm_data_factory" "www_adf" {
  name                   = var.adf_name
  location               = var.loca
  resource_group_name    = var.rgname
  public_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}
