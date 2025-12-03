resource "azurerm_service_plan" "function" {
  name                = "www-function-plan"
  resource_group_name = var.rgname
  location            = var.loca
  os_type             = "Linux"
  sku_name            = "Y1"
}
resource "azurerm_linux_function_app" "image_processor" {
  name                       = "www-image-processor"
  resource_group_name        = var.rgname
  location                   = var.loca
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key
  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
  app_settings = {
    "STORAGE_CONNECTION_STRING" = var.storage_connection_string
    "THUMBNAIL_WIDTH"           = "300"
    "THUMBNAIL_HEIGHT"          = "300"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Image-Processor"
    ManagedBy   = "Terraform"
  }
}
