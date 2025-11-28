resource "azurerm_linux_virtual_machine_scale_set" "www_vmss" {
  name                = "${var.teamuser}-vmss"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = var.loca2
  sku                 = "Standard_D2s_v3"
  instances           = 1
  upgrade_mode        = "Manual"
  source_image_id     = azurerm_shared_image_version.www_version.id
  admin_username      = "www"

  user_data = base64encode(file("03_sh_vmss.sh"))

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  admin_ssh_key {
    username   = "www"
    public_key = file("./id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name    = "${var.teamuser}-vmss-nic"
    primary = true

    ip_configuration {
      name                                         = "${var.teamuser}-vmss-nic"
      subnet_id                                    = azurerm_subnet.www_vmss.id
      application_gateway_backend_address_pool_ids = [one(azurerm_application_gateway.www_appgw.backend_address_pool).id]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  depends_on = [azurerm_shared_image_version.www_version]
}
