resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "my-vmss"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Standard_B2s"
  instances           = 1
  admin_username      = var.admin_username
  source_image_id     = azurerm_shared_image_version.version.id
  upgrade_mode        = "Manual"

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.vmss_subnet_id
      load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
    }
  }
  
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }
  
  user_data = base64encode(file("${path.module}/../../scripts/ins.sh"))
}
