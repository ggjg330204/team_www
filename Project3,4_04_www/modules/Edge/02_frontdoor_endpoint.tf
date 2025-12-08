resource "azurerm_cdn_frontdoor_endpoint" "www_fd_endpoint" {
  name                     = "www-fd-endpoint-${random_string.cdn_suffix.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
}

resource "azurerm_cdn_frontdoor_secret" "kv_cert_secret" {
  count                    = var.keyvault_certificate_secret_id != "" ? 1 : 0
  name                     = "www-kv-cert-secret"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id

  secret {
    customer_certificate {
      key_vault_certificate_id = var.keyvault_certificate_secret_id
    }
  }

  depends_on = [azurerm_role_assignment.frontdoor_kv_role]
}

resource "azurerm_cdn_frontdoor_custom_domain" "www_custom_domain" {
  name                     = "www-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  host_name                = "www.${var.domain_name}"

  tls {
    certificate_type        = var.keyvault_certificate_secret_id != "" ? "CustomerCertificate" : "ManagedCertificate"
    cdn_frontdoor_secret_id = var.keyvault_certificate_secret_id != "" ? azurerm_cdn_frontdoor_secret.kv_cert_secret[0].id : null
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "apex_custom_domain" {
  name                     = "apex-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  host_name                = var.domain_name

  tls {
    certificate_type        = var.keyvault_certificate_secret_id != "" ? "CustomerCertificate" : "ManagedCertificate"
    cdn_frontdoor_secret_id = var.keyvault_certificate_secret_id != "" ? azurerm_cdn_frontdoor_secret.kv_cert_secret[0].id : null
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
    path                = "/"
    protocol            = "Http"
    request_type        = "GET"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "www_fd_origin" {
  name                           = "www-fd-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.www_fd_origin_group.id
  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = var.appgw_public_ip != "" ? var.appgw_public_ip : var.lb_public_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.appgw_public_ip != "" ? var.appgw_public_ip : var.lb_public_ip
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
  forwarding_protocol           = "HttpOnly"
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
