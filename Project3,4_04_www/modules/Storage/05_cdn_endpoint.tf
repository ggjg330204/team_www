resource "azurerm_cdn_frontdoor_endpoint" "www_fd_endpoint" {
  name                     = "www-fd-endpoint-${random_string.cdn_suffix.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
}

resource "azurerm_cdn_frontdoor_custom_domain" "www_custom_domain" {
  name                     = "www-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  host_name                = "www.04www.cloud"

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "apex_custom_domain" {
  name                     = "apex-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  host_name                = "04www.cloud"

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "www_fd_origin_group" {
  name                     = "www-fd-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  session_affinity_enabled = false
  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }
  health_probe {
    path                = "/health.html"
    protocol            = "Http"
    request_type        = "HEAD"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "www_fd_origin" {
  name                           = "www-fd-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.www_fd_origin_group.id
  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = var.lb_public_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.lb_public_ip
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "www_fd_route" {
  name                          = "www-fd-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.www_fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.www_fd_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.www_fd_origin.id]
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "MatchRequest"
  link_to_default_domain        = true
  https_redirect_enabled        = true

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.www_custom_domain.id,
    azurerm_cdn_frontdoor_custom_domain.apex_custom_domain.id
  ]
}

resource "random_string" "cdn_suffix" {
  length  = 6
  special = false
  upper   = false
}