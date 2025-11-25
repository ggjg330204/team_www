# Shared Image Gallery - VM에서 커스텀 이미지 생성

# web2 VM 할당 해제 (이미지 생성을 위해 필요)
resource "null_resource" "www_web2_deallocate" {
  triggers = {
    virtual_machine_id = azurerm_linux_virtual_machine.www_web2vm.id
  }
  provisioner "local-exec" {
    command = "az vm deallocate --ids ${azurerm_linux_virtual_machine.www_web2vm.id}"
  }
  depends_on = [azurerm_linux_virtual_machine.www_web2vm]
}

# web2 VM의 OS 디스크 복사
resource "azurerm_managed_disk" "www_disk" {
  name                = "www-disk"
  location            = var.loca
  resource_group_name = var.rgname

  storage_account_type = "StandardSSD_LRS"
  create_option        = "Copy"
  disk_size_gb         = 10

  # web2 OS 디스크 복사
  source_resource_id = azurerm_linux_virtual_machine.www_web2vm.os_disk[0].id

  depends_on = [null_resource.www_web2_deallocate]
}

# 관리 디스크를 기반으로 커스텀 이미지 생성 (일반화됨)
resource "azurerm_image" "www_image" {
  name                = "www-image"
  location            = var.loca
  resource_group_name = var.rgname

  hyper_v_generation = "V2"

  os_disk {
    managed_disk_id = azurerm_managed_disk.www_disk.id
    os_type         = "Linux"
    os_state        = "Generalized"
    caching         = "ReadWrite"
    storage_type    = "StandardSSD_LRS"
  }
  depends_on = [azurerm_managed_disk.www_disk]
}

# 공유 이미지 갤러리 생성
resource "azurerm_shared_image_gallery" "www_gallery" {
  name                = "wwwgallery"
  location            = var.loca
  resource_group_name = var.rgname
}

# 갤러리 내 이미지 정의
resource "azurerm_shared_image" "www_sig_image" {
  name                = "www-image"
  gallery_name        = azurerm_shared_image_gallery.www_gallery.name
  resource_group_name = var.rgname
  location            = var.loca

  os_type            = "Linux"
  hyper_v_generation = "V2"
  architecture       = "x64"

  min_recommended_vcpu_count   = 1
  max_recommended_vcpu_count   = 2
  min_recommended_memory_in_gb = 2
  max_recommended_memory_in_gb = 4

  identifier {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
  }
}

# 이미지 버전 1.0.0 생성
resource "azurerm_shared_image_version" "www_version" {
  name                = "1.0.0"
  gallery_name        = azurerm_shared_image_gallery.www_gallery.name
  resource_group_name = var.rgname
  location            = var.loca

  image_name       = azurerm_shared_image.www_sig_image.name
  managed_image_id = azurerm_image.www_image.id

  target_region {
    name                   = "koreacentral"
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }

  depends_on = [azurerm_shared_image.www_sig_image, azurerm_image.www_image]
}
