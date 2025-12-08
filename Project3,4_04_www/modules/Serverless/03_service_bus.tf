resource "azurerm_servicebus_namespace" "main" {
  name                = "www-servicebus"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  tags = {
    Environment = "Production"
    Purpose     = "Message-Queue"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_servicebus_queue" "email" {
  name                  = "email-queue"
  namespace_id          = azurerm_servicebus_namespace.main.id
  max_size_in_megabytes = 1024
}
resource "azurerm_servicebus_queue" "image_processing" {
  name                                 = "image-processing-queue"
  namespace_id                         = azurerm_servicebus_namespace.main.id
  dead_lettering_on_message_expiration = true
}
resource "azurerm_servicebus_topic" "notifications" {
  name         = "notifications-topic"
  namespace_id = azurerm_servicebus_namespace.main.id
}
resource "azurerm_servicebus_subscription" "email_notifications" {
  name               = "email-notifications"
  topic_id           = azurerm_servicebus_topic.notifications.id
  max_delivery_count = 10
}
