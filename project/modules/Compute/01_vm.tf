#source\10_vm.tf
resource "azurerm_linux_virtual_machine" "hamap_basvm" {
  name                  = "${var.teamuser}-basvm"
  resource_group_name   = var.rgname
  location              = var.loca
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [var.nic_id]

  admin_ssh_key {
    username   = "www"
    public_key = file("${path.module}/../../ssh/id_ed25519.pub")
  }
  # user_data = base64encode(file("*")) 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.3.20231113"
  }
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }
  boot_diagnostics {
    storage_account_uri = null
  }
}
