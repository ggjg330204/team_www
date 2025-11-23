#mdoules/15_vmss.tf/data 안넣음 . vmss 서브넷 생성해야함
resource "azurerm_linux_virtual_machine_scale_set" "www_vmss" {
  name                = "www-vmss"
  resource_group_name = var.rgname
  location            = var.loca
  instances           = 1
  source_image_id     = azurerm_shared_image_version.www_version.id
  admin_username      = "www"
  sku                 = "Standard_B2s"
  upgrade_mode        = "Manual"
  #user_data           = base64encode(file("web.sh"))

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  admin_ssh_key {
    username   = "www"
    public_key = file("./id_ed25519.pub.txt")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name                      = "www-vmssnic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.www_nsg_http.id
    ip_configuration {
      name                                   = "www-vmss-ip"
      subnet_id                              = azurerm_subnet.www_vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.hyb_back.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}
