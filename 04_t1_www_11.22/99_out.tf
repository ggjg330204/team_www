# Terraform Outputs

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.rg.name
}

output "lb_public_ip" {
  description = "Load Balancer Public IP Address"
  value       = module.network_central.lb_public_ip
}

output "bastion_public_ip" {
  description = "Bastion Public IP Address"
  value       = module.network_central.bastion_public_ip
}

output "vmss_info" {
  description = "VMSS Information"
  value = {
    vmss_id   = module.compute.vmss_id
    vmss_name = "my-vmss"
  }
}

output "mysql_server_name" {
  description = "MySQL Server FQDN"
  value       = "www-mysql-server.mysql.database.azure.com"
}

output "vnet_peering_status" {
  description = "VNet Peering Information"
  value = {
    central_to_south = azurerm_virtual_network_peering.central_to_south.name
    south_to_central = azurerm_virtual_network_peering.south_to_central.name
  }
}
