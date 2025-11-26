#source\14_gallery.tf
# vm_web2 deallocate
resource "null_resource" "www_web2_deallocate" {
    triggers = {
    virtual_machine_id = azurerm_linux_virtual_machine.www_web2vm.id
}
provisioner "local-exec" {
    command = "az vm deallocate --ids ${azurerm_linux_virtual_machine.www_web2vm.id}"
  }
  depends_on = [ azurerm_linux_virtual_machine.www_web2vm ]
}

# vm_web2의 os 디스크 복사
resource "azurerm_managed_disk" "www_disk" {
    name = "www-disk"
    location = var.loca
    resource_group_name = azurerm_resource_group.www_rg.name

    storage_account_type = "StandardSSD_LRS"
    create_option = "Copy"
    disk_size_gb = 10

#web2의 os 디스크 복사
source_resource_id = azurerm_linux_virtual_machine.www_web2vm.os_disk[0].id

depends_on = [ null_resource.www_web2_deallocate ]
}
#managed disk 기반 커스텀 이미지 생성(specialized)
resource "azurerm_image" "www_image" {
    name = "www-image"
    location = var.loca
    resource_group_name = azurerm_resource_group.www_rg.name

    hyper_v_generation = "V2"
    
    os_disk {
        managed_disk_id = azurerm_managed_disk.www_disk.id
        os_type = "Linux"
        os_state = "Generalized"
        caching = "ReadWrite"
        storage_type = "StandardSSD_LRS"
    }
    depends_on = [ azurerm_managed_disk.www_disk ]
}
#shared image gallery 생성
resource "azurerm_shared_image_gallery" "www_gallery" {
    name = "www_gallery"
    location = var.loca
    resource_group_name = azurerm_resource_group.www_rg.name
}
#define image in gallery
resource "azurerm_shared_image" "www_sig_image" {
    name = "www-image"
    gallery_name = azurerm_shared_image_gallery.www_gallery.name
    resource_group_name = azurerm_resource_group.www_rg.name
    location = var.loca

    os_type = "Linux"
    hyper_v_generation = "V2"
    architecture = "x64"

    min_recommended_vcpu_count = 1
    max_recommended_vcpu_count = 2
    min_recommended_memory_in_gb = 2
    max_recommended_memory_in_gb = 4

    identifier {
        publisher = "resf"
        offer = "rockylinux-x86_64"
        sku = "9-lvm"
    }
}
# 실제 사용 버전 1.0.0 생성
resource "azurerm_shared_image_version" "www_version" {
    name = "1.0.0"
    gallery_name =azurerm_shared_image_gallery.www_gallery.name
    resource_group_name = azurerm_resource_group.www_rg.name
    location = var.loca

    image_name = azurerm_shared_image.www_sig_image.name
    managed_image_id = azurerm_image.www_image.id

    target_region {
        name = "koreacentral"
        regional_replica_count = 1
        storage_account_type = "Standard_LRS"
    }

depends_on = [azurerm_shared_image.www_sig_image, azurerm_image.www_image]
}
