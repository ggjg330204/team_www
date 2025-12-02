resource "azurerm_cdn_frontdoor_endpoint" "www_fd_endpoint" {
  name                     = "www-fd-endpoint-${random_string.cdn_suffix.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_fd_profile.id
}

resource "azurerm_cdn_frontdoor_origin_group" "www_fd_origin_group" {
  name                     = "www-fd-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_fd_profile.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "www_fd_origin" {
  name                          = "www-fd-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.www_fd_origin_group.id

  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = azurerm_storage_account.www_sa.primary_blob_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_storage_account.www_sa.primary_blob_host
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

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true
    content_types_to_compress = [
      "application/eot",
      "application/font",
      "application/font-sfnt",
      "application/javascript",
      "application/json",
      "application/opentype",
      "application/otf",
      "application/pkcs7-mime",
      "application/truetype",
      "application/ttf",
      "application/vnd.ms-fontobject",
      "application/xhtml+xml",
      "application/xml",
      "application/xml+rss",
      "application/x-font-opentype",
      "application/x-font-truetype",
      "application/x-font-ttf",
      "application/x-javascript",
      "font/eot",
      "font/opentype",
      "font/otf",
      "font/ttf",
      "image/svg+xml",
      "text/css",
      "text/csv",
      "text/html",
      "text/javascript",
      "text/js",
      "text/plain",
      "text/richtext",
      "text/tab-separated-values",
      "text/xml",
      "text/x-script",
      "text/x-component",
      "text/x-java-source"
    ]
  }
}

resource "random_string" "cdn_suffix" {
  length  = 4
  special = false
  upper   = false
}
