output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vm_principal_id" {
  description = "Principal ID of the Web VM's managed identity"
  value       = azurerm_linux_virtual_machine.webvm.identity[0].principal_id
}
