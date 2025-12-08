output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}
output "hub_vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}
output "firewall_private_ip" {
  value = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}
output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion_subnet.id
}

output "bastion_host_name" {
  value = azurerm_bastion_host.hub_bastion.name
}
