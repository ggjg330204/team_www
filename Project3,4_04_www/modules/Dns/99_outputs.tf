output "dns_zone_id" {
  description = "The ID of the DNS Zone"
  value       = azurerm_dns_zone.public.id
}

output "dns_zone_name" {
  description = "The name of the DNS Zone"
  value       = azurerm_dns_zone.public.name
}
