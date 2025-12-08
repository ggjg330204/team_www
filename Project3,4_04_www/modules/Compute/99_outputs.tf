output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}
output "was_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.was_vmss.id
}
output "aci_ip" {
  value = azurerm_container_group.aci.ip_address
}


output "mail_vm_public_ip" {
  value = azurerm_public_ip.mail_pip.ip_address
}

output "mail_vm_private_ip" {
  value = azurerm_linux_virtual_machine.mail_vm.private_ip_address
}

