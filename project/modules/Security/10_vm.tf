#project\modules\Security\10_vm.tf
resource "azurerm_linux_virtual_machine" "hj_vm_bas" {
  name                  = "hj-vm-bas"
  resource_group_name   = var.rgname
  location              = var.loca
  size                  = "Standard_B2als_v2"
  admin_username        = "www"
  network_interface_ids = [ azurerm_network_interface.hj_nic_bas.id ]

  admin_ssh_key {
    username   = "www"
    public_key = file("id_ed25519.pub")
  }
  user_data = base64encode(file("bas.sh")) 

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

resource "azurerm_linux_virtual_machine" "hj_vm_web" {
  name                  = "hj-vm-web"
  resource_group_name   = var.rgname
  location              = var.loca
  size                  = "Standard_B2als_v2"
  admin_username        = "www"
  network_interface_ids = [ azurerm_network_interface.hj_nic_web.id ]

  admin_ssh_key {
    username   = "www"
    public_key = file("id_ed25519.pub")
  }
  user_data = base64encode(file("web.sh")) 

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

resource "azurerm_linux_virtual_machine" "hj_vm_db" {
  name                  = "hj-vm-db"
  resource_group_name   = var.rgname
  location              = var.loca
  size                  = "Standard_B2als_v2"
  admin_username        = "www"
  network_interface_ids = [ azurerm_network_interface.hj_nic_db.id ]

  admin_ssh_key {
    username   = "www"
    public_key = file("id_ed25519.pub")
  }
  user_data = base64encode(file("sql.sh")) 

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