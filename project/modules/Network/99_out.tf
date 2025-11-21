output "subnet_id" {
  value = azurerm_subnet.www_bas.id
}
output "nic_id" { value = azurerm_network_interface.www_bas_nic.id }
