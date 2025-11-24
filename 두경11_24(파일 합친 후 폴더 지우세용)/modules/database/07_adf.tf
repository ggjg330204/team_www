resource "azurerm_data_factory" "www_adf" {
  name                = "www-adf"
  location            = var.loca
  resource_group_name = var.rgname
}

resource "azurerm_data_factory_pipeline" "pipeline" {
  name            = "DailySync"
  data_factory_id = azurerm_data_factory.www_adf.id
}
