output "bas_pub_ip" {
  description = "Bastion 호스트의 공인 IP 주소"
  value       = azurerm_public_ip.www_basip.ip_address
}

# output "rg_name" {
#   description = "리소스 그룹 이름"
#   value       = azurerm_resource_group.www_rg.name
# }

# output "rg_id" {
#   description = "리소스 그룹 ID"
#   value       = azurerm_resource_group.www_rg.id
# }

output "vnet_id" {
  description = "메인 가상 네트워크 ID (vnet0 - Korea Central)"
  value       = azurerm_virtual_network.www_vnet0.id
}

output "vnet_south_id" {
  description = "보조 가상 네트워크 ID (vnet1 - Korea South)"
  value       = azurerm_virtual_network.www_vnet1.id
}

output "bas_subnet_id" {
  description = "Bastion 서브넷 ID"
  value       = azurerm_subnet.www_bas.id
}

output "web1_subnet_id" {
  description = "Web1 서브넷 ID"
  value       = azurerm_subnet.www_web1.id
}

output "web2_subnet_id" {
  description = "Web2 서브넷 ID"
  value       = azurerm_subnet.www_web2.id
}

output "db_subnet_id" {
  description = "데이터베이스 서브넷 ID"
  value       = azurerm_subnet.www_db.id
}

output "storage_subnet_id" {
  description = "스토리지 서브넷 ID (Private Endpoint용으로 DB 서브넷 공유)"
  value       = azurerm_subnet.www_db.id
}

output "web1_v1_subnet_id" {
  description = "Web1 V1 (South) 서브넷 ID"
  value       = azurerm_subnet.www_web1_v1.id
}

output "vmss_subnet_id" {
  description = "VMSS 서브넷 ID"
  value       = azurerm_subnet.www_vmss.id
}

output "nic_id" {
  description = "네트워크 인터페이스(NIC) ID 목록"
  value = {
    bas_nic     = azurerm_network_interface.www_bas_nic.id
    web1_nic    = azurerm_network_interface.www_web1_nic.id
    web2_nic    = azurerm_network_interface.www_web2_nic.id
    db_nic      = azurerm_network_interface.www_db_nic.id
    web1_v1_nic = azurerm_network_interface.www_web1_v1_nic.id
    web2_v1_nic = azurerm_network_interface.www_web2_v1_nic.id
  }
}
