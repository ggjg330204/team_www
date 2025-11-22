output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "bastion_public_ip" {
  value = var.enable_bastion ? azurerm_public_ip.bastion_pip[0].ip_address : null
}

output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bpepool.id
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb_pip.ip_address
}
