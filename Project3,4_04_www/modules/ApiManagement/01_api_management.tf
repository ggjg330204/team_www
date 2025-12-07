resource "azurerm_api_management" "main" {
  name                = "www-apim"
  location            = var.loca
  resource_group_name = var.rgname
  publisher_name      = "WordPress Team"
  publisher_email     = "admin@example.com"
  sku_name            = "Standard_1"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
    Purpose     = "API-Management"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_api_management_api" "wordpress" {
  name                = "wordpress-api"
  resource_group_name = var.rgname
  api_management_name = azurerm_api_management.main.name
  revision            = "1"
  display_name        = "WordPress REST API"
  path                = "wp-json"
  protocols           = ["https"]
  service_url         = "http:
  subscription_required = true
}
resource "azurerm_api_management_api_policy" "wordpress_policy" {
  api_name            = azurerm_api_management_api.wordpress.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.rgname
  xml_content = <<XML
<policies>
  <inbound>
    <rate-limit calls="100" renewal-period="60" />
    <quota calls="10000" renewal-period="86400" />
    <cors allow-credentials="false">
      <allowed-origins>
        <origin>https:
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
      </allowed-methods>
    </cors>
  </inbound>
  <backend>
    <forward-request />
  </backend>
  <outbound />
  <on-error />
</policies>
XML
}
