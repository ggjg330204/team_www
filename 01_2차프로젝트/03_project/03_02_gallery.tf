resource "null_resource" "www_web2_deallocate" {
  triggers = {
    virtual_machine_id = azurerm_linux_virtual_machine.www_web2vm.id
  }
  provisioner "local-exec" {
    command = "az vm deallocate --ids ${azurerm_linux_virtual_machine.www_web2vm.id}"
  }
  depends_on = [azurerm_linux_virtual_machine.www_web2vm]
}

resource "azurerm_managed_disk" "www_disk" {
  name                 = "www-disk"
  location             = var.loca
  resource_group_name  = azurerm_resource_group.www_rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Copy"
  disk_size_gb         = 30
  source_resource_id   = azurerm_linux_virtual_machine.www_web2vm.os_disk[0].id

  depends_on = [null_resource.www_web2_deallocate]
}

resource "azurerm_image" "www_image" {
  name                = "www-image"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
  hyper_v_generation  = "V2"

  os_disk {
    os_type         = "Linux"
    os_state        = "Generalized"
    managed_disk_id = azurerm_managed_disk.www_disk.id
    caching         = "ReadWrite"
    storage_type    = "StandardSSD_LRS"
  }
}

resource "azurerm_shared_image_gallery" "www_gallery" {
  name                = "${var.teamuser}gallery${random_string.gallery_suffix.result}"
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name
}

resource "random_string" "gallery_suffix" {
  length  = 2
  special = false
  upper   = false
}

resource "azurerm_shared_image" "www_sig_image" {
  name                = "${var.teamuser}-image"
  gallery_name        = azurerm_shared_image_gallery.www_gallery.name
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = var.loca
  os_type             = "Linux"
  hyper_v_generation  = "V2"
  architecture        = "x64"

  identifier {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
  }
}

resource "azurerm_shared_image_version" "www_version" {
  name                = "1.0.0"
  gallery_name        = azurerm_shared_image_gallery.www_gallery.name
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = var.loca
  managed_image_id    = azurerm_image.www_image.id
  image_name          = azurerm_shared_image.www_sig_image.name

  target_region {
    name                   = "koreacentral"
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }

  target_region {
    name                   = "koreasouth"
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }

  depends_on = [azurerm_shared_image.www_sig_image, azurerm_image.www_image]
}
