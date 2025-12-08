output "frontdoor_endpoint_hostname" {
  description = "The hostname of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.www_fd_endpoint.host_name
}

output "frontdoor_endpoint_id" {
  description = "The ID of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.www_fd_endpoint.id
}

output "www_custom_domain_validation_token" {
  description = "Validation token for www subdomain - Add this as TXT record: _dnsauth.www.<your-domain>"
  value       = azurerm_cdn_frontdoor_custom_domain.www_custom_domain.validation_token
}

output "apex_custom_domain_validation_token" {
  description = "Validation token for apex domain - Add this as TXT record: _dnsauth.<your-domain>"
  value       = azurerm_cdn_frontdoor_custom_domain.apex_custom_domain.validation_token
}

output "www_custom_domain_id" {
  description = "The ID of www custom domain"
  value       = azurerm_cdn_frontdoor_custom_domain.www_custom_domain.id
}

output "apex_custom_domain_id" {
  description = "The ID of apex custom domain"
  value       = azurerm_cdn_frontdoor_custom_domain.apex_custom_domain.id
}
