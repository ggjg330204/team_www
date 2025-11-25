resource "azurerm_linux_virtual_machine_scale_set" "www_vmss" {
  name                = "${var.teamuser}-vmss"
  resource_group_name = var.rgname
  location            = var.loca

  instances       = 1
  sku             = "Standard_B2s"
  upgrade_mode    = "Manual"
  source_image_id = azurerm_shared_image_version.www_version.id
  admin_username  = "www"

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  admin_ssh_key {
    username   = "www"
    public_key = file("${path.root}/ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name    = "${var.teamuser}-vmss-nic"
    primary = true

    ip_configuration {
      name      = "${var.teamuser}-vmss-nic"
      subnet_id = var.vmss_subnet_id
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  depends_on = [azurerm_shared_image_version.www_version]
}
