output "bas_pub_ip" {
  value = azurerm_public_ip.www_basip.ip_address
}

output "rg_name" {
  value = azurerm_resource_group.www_rg.name
}

output "vnet_id" {
  description = "The ID of the main virtual network (vnet0)"
  value       = azurerm_virtual_network.www_vnet0.id
}

output "vnet_south_id" {
  description = "The ID of the south virtual network (vnet1)"
  value       = azurerm_virtual_network.www_vnet1.id
}

output "db_subnet_id" {
  description = "Database subnet ID"
  value       = azurerm_subnet.www_db.id
}

output "storage_subnet_id" {
  description = "Storage subnet ID"
  value       = azurerm_subnet.www_db.id
}

output "nic_id" {
  description = "Network interface IDs"
  value = {
    bas_nic     = azurerm_network_interface.www_bas_nic.id
    web1_nic    = azurerm_network_interface.www_web1_nic.id
    web2_nic    = azurerm_network_interface.www_web2_nic.id
    db_nic      = azurerm_network_interface.www_db_nic.id
    web1_v1_nic = azurerm_network_interface.www_web1_v1_nic.id
    web2_v1_nic = azurerm_network_interface.www_web2_v1_nic.id
  }
}

output "vmss_subnet_id" {
  description = "VMSS subnet ID"
  value       = azurerm_subnet.www_vmss.id
}


output "rg_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.www_rg.id
}
