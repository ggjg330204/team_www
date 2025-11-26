#modules\vm.tf\04-1_appgw.tf
locals {
  backend_address_pool_name          = "${azurerm_subnet.www_vnet.id}-beap"
  frontend_port_name             = "${azurerm_subnet.www_vnet.id}-feport"
  frontend_ip_configuration_name = "${azurerm_subnet.www_vnet.id}-feip"
  http_setting_name             = "${azurerm_subnet.www_vnet.id}-be-htst"
  listener_name                 = "${azurerm_subnet.www_vnet.id}-httplstn"
  request_routing_rule_name     = "${azurerm_subnet.www_vnet.id}-rqrt"
  redirect_configuration_name   = "${azurerm_subnet.www_vnet.id}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "www-appgateway"
  resource_group_name = var.rgname
  location            = var.loca


  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "www-gateway-ip-configuration"
    subnet_id = azurerm_subnet.www_load.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.www_loadip.id
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
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
