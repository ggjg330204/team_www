output "subnet_id" {
  value = azurerm_subnet.www_bas.id
}
output "nic_id" {
  value = azurerm_network_interface.www_bas_nic.id
}

output "rg_name" {
  value       = azurerm_resource_group.www_rg.name
  description = "생성된 리소스 그룹의 이름"
}
