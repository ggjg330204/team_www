locals {
  backend_address_pool_name      = "www-beap"
  frontend_port_name             = "www-feport"
  frontend_ip_configuration_name = "www-feip"
  http_setting_name              = "www-be-htst"
  listener_name                  = "www-httplstn"
  request_routing_rule_name      = "www-rqrt"
  redirect_configuration_name    = "www-rdrcfg"
}

resource "azurerm_application_gateway" "www_appgw" {
  name                = "www-appgw"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = var.loca2

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "www-ip-appgw"
    subnet_id = azurerm_subnet.www_appgw.id

  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.www_appip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
