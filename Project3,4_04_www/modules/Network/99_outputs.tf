output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnets : k => v.id }
}
output "subnet_prefixes" {
  value = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes[0] }
}
output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bpepool.id
}
output "lb_probe_id" {
  value = azurerm_lb_probe.vmss_probe.id
}

output "appgw_backend_pool_id" {
  value = var.enable_appgw ? tolist(azurerm_application_gateway.appgw[0].backend_address_pool)[0].id : null
}
output "lb_public_ip" {
  value = azurerm_public_ip.lb_pip.ip_address
}
output "lb_public_ip_id" {
  value = azurerm_public_ip.lb_pip.id
}
output "ssh_nat_pool_id" {
  value = azurerm_lb_nat_pool.ssh_nat_pool.id
}
output "was_lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.was_backend_pool.id
}
output "was_lb_private_ip" {
  value = azurerm_lb.was_lb.frontend_ip_configuration[0].private_ip_address
}
output "was_lb_probe_id" {
  value = azurerm_lb_probe.was_probe.id
}
output "appgw_public_ip" {
  value = var.enable_appgw ? azurerm_public_ip.appgw_pip[0].ip_address : ""
}
output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.www_tm.fqdn
}
output "appgw_identity_principal_id" {
  value = var.appgw_identity_principal_id
}
output "enable_appgw" {
  value = var.enable_appgw
}
output "appgw_key_vault_id" {
  value = var.enable_appgw && var.enable_ssl ? try(data.azurerm_key_vault.appgw_kv[0].id, "") : ""
}