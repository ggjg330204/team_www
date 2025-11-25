# Compute 모듈 출력

output "vm_ids" {
  description = "모든 가상 머신(VM)의 ID 목록"
  value = {
    bastion_vm = azurerm_linux_virtual_machine.www_basvm.id
    web1_vm    = azurerm_linux_virtual_machine.www_web1vm.id
    web2_vm    = azurerm_linux_virtual_machine.www_web2vm.id
    db_vm      = azurerm_linux_virtual_machine.www_dbvm.id
    web1_v1_vm = azurerm_linux_virtual_machine.www_vnet1_web1vm.id
  }
}

output "vmss_id" {
  description = "가상 머신 확장 집합(VMSS) ID"
  value       = azurerm_linux_virtual_machine_scale_set.www_vmss.id
}

output "shared_image_gallery_id" {
  description = "공유 이미지 갤러리 ID"
  value       = azurerm_shared_image_gallery.www_gallery.id
}

output "shared_image_version_id" {
  description = "공유 이미지 버전 ID"
  value       = azurerm_shared_image_version.www_version.id
}
