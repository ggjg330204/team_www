resource "azurerm_api_management" "main" {
  name                = "www-apim"
  location            = var.loca
  resource_group_name = var.rgname
  publisher_name      = "WordPress Team"
  publisher_email     = var.publisher_email
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
  name                  = "wordpress-api"
  resource_group_name   = var.rgname
  api_management_name   = azurerm_api_management.main.name
  revision              = "1"
  display_name          = "WordPress REST API"
  path                  = "wp-json"
  protocols             = ["https"]
  service_url           = "http://${var.lb_private_ip}"
  subscription_required = false
}

# API Policy는 Azure Portal에서 수동 설정 필요
# Rate Limit, Quota, CORS 등의 정책은 Portal에서 구성
