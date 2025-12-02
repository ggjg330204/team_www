resource "azurerm_shared_image_gallery" "gallery" {
  name                = "mygallery${random_string.suffix.result}"
  resource_group_name = var.rgname
  location            = var.loca
}
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_shared_image" "image" {
  name                = "my-image"
  gallery_name        = azurerm_shared_image_gallery.gallery.name
  resource_group_name = var.rgname
  location            = var.loca
  os_type             = "Linux"
  hyper_v_generation  = "V2"
  identifier {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
  }
  purchase_plan {
    name      = "9-lvm"
    publisher = "resf"
    product   = "rockylinux-x86_64"
  }
}
resource "azurerm_snapshot" "snapshot" {
  name                = "webvm-snapshot"
  location            = var.loca
  resource_group_name = var.rgname
  create_option       = "Copy"
  source_uri          = azurerm_linux_virtual_machine.webvm.os_disk[0].id
  depends_on = [azurerm_linux_virtual_machine.webvm]
}
resource "azurerm_shared_image_version" "version" {
  name                = "1.0.0"
  gallery_name        = azurerm_shared_image_gallery.gallery.name
  resource_group_name = var.rgname
  location            = var.loca
  image_name          = azurerm_shared_image.image.name
  os_disk_snapshot_id = azurerm_snapshot.snapshot.id
  target_region {
    name                   = var.loca
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
}
