output "function_app_id" {
  value = azurerm_linux_function_app.image_processor.id
}
output "function_app_name" {
  value = azurerm_linux_function_app.image_processor.name
}
output "servicebus_namespace_id" {
  value = azurerm_servicebus_namespace.main.id
}
