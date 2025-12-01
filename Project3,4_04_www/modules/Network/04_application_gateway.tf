resource "azurerm_public_ip" "appgw_pip" {
  count               = var.enable_appgw ? 1 : 0
  name                = "www-appgw-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1", "2"]
  tags = {
    Environment = "Production"
    Purpose     = "Application-Gateway"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes = [zones, tags]
  }
}
data "azurerm_key_vault_certificate" "ssl" {
  count        = var.enable_appgw && var.enable_ssl ? 1 : 0
  name         = "www-ssl-cert"
  key_vault_id = var.keyvault_id
}
resource "azurerm_application_gateway" "appgw" {
  count               = var.enable_appgw ? 1 : 0
  name                = "www-appgw"
  location            = var.loca
  resource_group_name = var.rgname
  zones = ["1", "2"]
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = lookup(azurerm_subnet.subnets, "www-appgw", null) != null ? azurerm_subnet.subnets["www-appgw"].id : null
  }
  frontend_port {
    name = "http-port"
    port = 80
  }
  dynamic "frontend_port" {
    for_each = var.enable_ssl ? [1] : []
    content {
      name = "https-port"
      port = 443
    }
  }
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip[0].id
  }
  dynamic "ssl_certificate" {
    for_each = var.enable_ssl ? [1] : []
    content {
      name                = "www-ssl-cert"
      key_vault_secret_id = data.azurerm_key_vault_certificate.ssl[0].secret_id
    }
  }
  dynamic "ssl_policy" {
    for_each = var.enable_ssl ? [1] : []
    content {
      policy_type = "Predefined"
      policy_name = "AppGwSslPolicy20220101"
    }
  }
  backend_address_pool {
    name = "www-backend-pool"
  }
  backend_http_settings {
    name                                = "www-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "www-health-probe"
  }
  http_listener {
    name                           = "www-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }
  dynamic "http_listener" {
    for_each = var.enable_ssl ? [1] : []
    content {
      name                           = "www-https-listener"
      frontend_ip_configuration_name = "appgw-frontend-ip"
      frontend_port_name             = "https-port"
      protocol                       = "Https"
      ssl_certificate_name           = "www-ssl-cert"
    }
  }
  dynamic "redirect_configuration" {
    for_each = var.enable_ssl ? [1] : []
    content {
      name                 = "http-to-https"
      redirect_type        = "Permanent"
      target_listener_name = "www-https-listener"
      include_path         = true
      include_query_string = true
    }
  }
  request_routing_rule {
    name                        = var.enable_ssl ? "http-redirect-rule" : "www-routing-rule"
    rule_type                   = "Basic"
    http_listener_name          = "www-listener"
    backend_address_pool_name   = var.enable_ssl ? null : "www-backend-pool"
    backend_http_settings_name  = var.enable_ssl ? null : "www-http-settings"
    redirect_configuration_name = var.enable_ssl ? "http-to-https" : null
    priority                    = 100
  }
  dynamic "request_routing_rule" {
    for_each = var.enable_ssl ? [1] : []
    content {
      name                       = "https-routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "www-https-listener"
      backend_address_pool_name  = "www-backend-pool"
      backend_http_settings_name = "www-http-settings"
      priority                   = 200
    }
  }
  probe {
    name                                      = "www-health-probe"
    protocol                                  = "Http"
    path                                      = "/health.html"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Application-Gateway-WAF"
    ManagedBy   = "Terraform"
  }
}
