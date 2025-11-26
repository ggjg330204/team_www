output "subnet_id" {
  value = azurerm_subnet.www_bas.id
}
output "nic_id" {
  value = azurerm_network_interface.www_bas_nic.id
}

output "rg_name" {
  value       = var.rgname
  description = "생성된 리소스 그룹의 이름"
}
#nic
output "subnet_www_bas_nic" {
  value = azurerm_network_interface.www_bas_nic.id
}
output "subnet_www_web1_nic" {
  value = azurerm_network_interface.www_web1_nic.id
}
output "subnet_www_web2_nic" {
  value = azurerm_network_interface.www_web2_nic.id
}
output "subnet_www_db_nic" {
  value = azurerm_network_interface.www_db_nic.id
}
# output "subnet_www_app_nic" {
#   value = azurerm_network_interface.www_app_nic.id
# }
output "subnet_www_web1_v1_nic" {
  value = azurerm_network_interface.www_web1_v1_nic.id
}
output "subnet_www_web2_v1_nic" {
  value = azurerm_network_interface.www_web2_v1_nic.id
}
output "backend_address_pool_ids" {
  value = [for p in azurerm_application_gateway.www_appgw.backend_address_pool : p.id]
}
#subnet
output "azurerm_subnet_www_bas" {
  value = azurerm_subnet.www_bas.id
}
output "azurerm_subnet_www_nat" {
  value = azurerm_subnet.www_nat.id
}
output "azurerm_subnet_www_web1" {
  value = azurerm_subnet.www_web1.id
}
output "azurerm_subnet_www_web2" {
  value = azurerm_subnet.www_web2.id
}
output "azurerm_subnet_www_db" {
  value = azurerm_subnet.www_db.id
}
# output "azurerm_subnet_www_app" {
#   value = azurerm_subnet.www_app.id
# }
output "azurerm_subnet_www_nat_v1" {
  value = azurerm_subnet.www_nat_v1.id
}
# output "azurerm_subnet_www_load" {
#   value = azurerm_subnet.www_load.id
# }
output "azurerm_subnet_www_web1_v1" {
  value = azurerm_subnet.www_web1_v1.id
}
output "azurerm_subnet_www_web2_v1" {
  value = azurerm_subnet.www_web2_v1.id
}

output "azurerm_subnet_www_vmss" {
  value = azurerm_subnet.www_vmss.id
}